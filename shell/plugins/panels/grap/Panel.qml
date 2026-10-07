import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Grap — instant content + filename search across the home directory.
// Wraps ripgrep (content) and fd (filenames). Type a query (debounced),
// pick a scope chip (~ | r2-d2 | .config) or prefix the query with an
// @path, and open a hit in Cursor at the exact line. ^Y copies
// path:line:col. Esc clears the query, or closes if it is already empty.
//
// Cursor is preferred for opening matches (falling back to the default
// editor via r2-d2-launch-editor when Cursor is not installed).
//
// Standalone panel plugin summoned with `r2-d2-shell shell toggle r2-d2.grap`.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property string fontFamily: Style.font.family
  property string query: ""
  property string scopeKey: "home"     // home | r2d2 | config
  property bool explicitScope: false    // query carries an @path
  property string scopeLabel: ""
  property bool caseSensitive: false
  property bool regexMode: true
  property var results: []
  property var fileResults: []
  property var contentResults: []
  property bool searching: false
  property string status: ""
  property int selected: 0
  property int hovered: -1
  // search-while-loading race guard
  property bool queued: false
  property string queuedQuery: ""
  readonly property int preCap: 28

  function open(payloadJson) {
    root.opened = true
    root.query = ""
    root.results = []
    root.fileResults = []
    root.contentResults = []
    root.status = ""
    root.scopeKey = "home"
    root.explicitScope = false
    root.caseSensitive = false
    root.regexMode = true
    root.selected = 0
    root.hovered = -1
    var pre = ""
    try { pre = (JSON.parse(payloadJson || "{}") || {}).query || "" } catch (e) {}
    Qt.callLater(function() {
      searchField.forceActiveFocus()
      if (pre) { searchField.text = pre; root.queueSearch(pre) }
    })
  }

  function close() {
    root.opened = false
    root.searching = false
    root.queued = false
    root.fileResults = []
    root.contentResults = []
    searchProc.running = false
    findProc.running = false
  }

  function dismiss() {
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "r2-d2.grap")
    else close()
  }

  function scopeRoot() {
    if (scopeKey === "r2d2") return Quickshell.env("HOME") + "/.local/share/r2-d2"
    if (scopeKey === "config") return Quickshell.env("HOME") + "/.config"
    return Quickshell.env("HOME")
  }

  function parseScope(q) {
    var m = /^@(\S+)\s+([\s\S]*)$/.exec(q.trim())
    if (!m) {
      root.explicitScope = false
      return { dir: scopeRoot(), pattern: q, label: scopeKey === "home" ? "" : scopeLabel }
    }
    var raw = m[1]
    var dir = raw.charAt(0) === "~" ? Quickshell.env("HOME") + raw.slice(1)
      : (raw.charAt(0) !== "/" ? Quickshell.env("HOME") + "/" + raw : raw)
    root.explicitScope = true
    return { dir: dir, pattern: m[2], label: shortPath(dir) }
  }

  function shortPath(p) {
    var h = Quickshell.env("HOME")
    return p.indexOf(h) === 0 ? "~" + p.slice(h.length) : p
  }

  function patternOf(q) {
    var m = /^@(\S+)\s+([\s\S]*)$/.exec(q.trim())
    return m ? m[2] : q
  }

  readonly property string activePattern: root.patternOf(root.query)

  function queueSearch(text) {
    root.query = text
    root.selected = 0
    var p = root.parseScope(text)
    root.scopeLabel = p.label
    if (p.pattern.trim().length < 2) {
      root.results = []
      root.status = p.label !== "" ? "in " + p.label + " — keep typing" : ""
      return
    }
    debounce.restart()
  }

  function startSearch(text) {
    var p = root.parseScope(text)
    if (p.pattern.trim().length < 2) return
    if (root.searching) {
      root.queued = true
      root.queuedQuery = text
      root.startFindFor(text)
      return
    }
    root.searching = true
    root.status = "searching" + (p.label !== "" ? " " + p.label : "") + "…"
    searchProc.command = (function() {
      var a = ["rg", "--vimgrep", "--no-heading", "--no-messages",
        "--hidden", "-M", "300", "--max-count", "5",
        "--glob", "!.git/", "--glob", "!.cache/", "--glob", "!node_modules/",
        "--glob", "!.mozilla/", "--glob", "!.local/share/Trash/"]
      a.push(root.caseSensitive ? "--case-sensitive" : "--smart-case")
      if (!root.regexMode) a.push("--fixed-strings")
      a.push("-e", p.pattern, p.dir)
      return a
    })()
    searchProc.running = true
    root.startFindFor(text)
  }

  function startFindFor(text) {
    var p = root.parseScope(text)
    if (p.pattern.trim().length < 2) return
    if (!/^[A-Za-z0-9@._+~\/ -]+$/.test(p.pattern)) return
    var dir = p.dir.replace(/'/g, "'\\''")
    var pat = p.pattern.replace(/'/g, "'\\''")
    findProc.command = ["sh", "-c",
      "fd -H -t f -F --max-results 30 --exclude .git --exclude node_modules --exclude .cache --exclude .mozilla --exclude Trash '" + pat + "' '" + dir + "' 2>/dev/null || true"]
    findProc.running = true
  }

  function mergeResults() {
    var files = root.fileResults.slice(0, 30)
    var content = root.contentResults.slice(0, Math.max(0, 150 - files.length))
    root.results = files.concat(content)
    if (root.selected >= root.results.length) root.selected = 0
    root.hovered = -1
    var where = root.scopeLabel !== "" ? "in " + root.scopeLabel + " · " : ""
    if (root.results.length === 0) root.status = where + "no matches"
    else root.status = where + files.length + " files + " + content.length + " hits"
  }

  function hlParts(snippet, pattern) {
    var s = String(snippet)
    if (!pattern) return { pre: s, hit: "", post: "" }
    var re
    try {
      re = new RegExp(root.regexMode ? pattern : pattern.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
                      root.caseSensitive ? "" : "i")
    } catch (e) { return { pre: s, hit: "", post: "" } }
    var m = re.exec(s)
    if (!m || m[0] === "") return { pre: s, hit: "", post: "" }
    var pre = s.slice(0, m.index)
    var cut = false
    if (pre.length > root.preCap) { pre = pre.slice(pre.length - root.preCap); cut = true }
    return { pre: (cut ? "…" : "") + pre, hit: m[0], post: s.slice(m.index + m[0].length) }
  }

  function openResult(r) {
    if (!r) return
    var loc = r.file + ":" + r.line
    Quickshell.execDetached(["sh", "-c",
      "command -v cursor >/dev/null 2>&1 && exec uwsm-app -- cursor \"$1\" || exec r2-d2-launch-editor \"$1\"",
      "grap-open", loc])
    root.dismiss()
  }

  function copyResult(r) {
    if (!r) return
    var loc = r.file + ":" + r.line + ":" + r.col
    Quickshell.execDetached(["sh", "-c",
      "printf %s \"$1\" | (wl-copy 2>/dev/null || xclip -selection clipboard 2>/dev/null) && r2-d2-notification-send --app-name Grap -u low Copied \"$1\"",
      "grap-copy", loc])
  }

  Timer { id: debounce; interval: 300; onTriggered: root.startSearch(root.query) }

  Process {
    id: searchProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var out = []
        var lines = String(text || "").split("\n")
        for (var i = 0; i < lines.length; i++) {
          var m = /^(.+?):(\d+):(\d+):(.*)$/.exec(lines[i])
          if (m && out.length < 150)
            out.push({ file: m[1], line: parseInt(m[2], 10), col: parseInt(m[3], 10), snippet: m[4].trim(), isFile: false })
        }
        var hasQueued = root.queued
        var next = root.queuedQuery
        root.queued = false
        root.searching = false
        if (hasQueued) { root.startSearch(next); return }
        root.contentResults = out
        root.mergeResults()
      }
    }
  }

  Process {
    id: findProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var out = []
        var lines = String(text || "").split("\n")
        for (var i = 0; i < lines.length && out.length < 30; i++) {
          var ln = lines[i].trim()
          if (ln) out.push({ file: ln, line: 1, col: 1, snippet: "", isFile: true })
        }
        root.fileResults = out
        root.mergeResults()
      }
    }
  }

  PanelWindow {
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "r2-d2-grap"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle {
      anchors.fill: parent
      color: Color.menu.scrim
      MouseArea { anchors.fill: parent; onClicked: root.dismiss() }
    }

    Item {
      id: keyCatcher
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: root.dismiss()

      Item {
        anchors.centerIn: parent
        width: card.width
        height: card.height
        scale: Math.min(1,
          (keyCatcher.width - Style.space(32)) / Math.max(1, width),
          (keyCatcher.height - Style.space(32)) / Math.max(1, height))
        MouseArea { anchors.fill: parent; onClicked: {} }

        Rectangle {
          id: card
          width: Math.min(Style.space(600), keyCatcher.width - Style.space(48))
          height: Math.min(Style.space(470), keyCatcher.height - Style.space(48))
          radius: Style.cornerRadius
          color: Color.popups.background
          border.width: 1
          border.color: Color.popups.border

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.space(14)
            spacing: Style.space(8)

            // hero search
            Rectangle {
              Layout.fillWidth: true
              Layout.preferredHeight: Style.space(48)
              radius: Style.cornerRadius
              color: Util.alpha(Color.foreground, 0.05)
              border.width: 1
              border.color: searchField.activeFocus
                ? Util.alpha(Color.accent, 0.5)
                : Util.alpha(Color.foreground, 0.12)
              Behavior on border.color { ColorAnimation { duration: 150 } }
              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Style.space(12)
                anchors.rightMargin: Style.space(10)
                spacing: Style.space(8)
                Text {
                  text: "\uF002"
                  color: Color.muted
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  Layout.alignment: Qt.AlignVCenter
                }
                TextField {
                  id: searchField
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  placeholderText: "Grep + find home…  (@path to scope)"
                  placeholderTextColor: Util.alpha(Color.muted, 0.6)
                  color: Color.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  font.weight: Font.DemiBold
                  background: null
                  selectByMouse: true
                  onTextChanged: root.queueSearch(text)
                  Keys.onPressed: function(e) {
                    if (e.key === Qt.Key_Down) { root.selected = Math.min(root.selected + 1, root.results.length - 1); root.hovered = -1; e.accepted = true }
                    else if (e.key === Qt.Key_Up) { root.selected = Math.max(root.selected - 1, 0); root.hovered = -1; e.accepted = true }
                    else if (e.key === Qt.Key_Escape) {
                      if (searchField.text !== "") { searchField.text = ""; root.queueSearch("") } else root.dismiss()
                      e.accepted = true
                    } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                      root.openResult(root.results[root.selected]); e.accepted = true
                    } else if (e.key === Qt.Key_Y && (e.modifiers & Qt.ControlModifier)) {
                      root.copyResult(root.results[root.selected]); e.accepted = true
                    } else if (e.key === Qt.Key_U && (e.modifiers & Qt.ControlModifier)) {
                      searchField.text = ""; root.queueSearch(""); e.accepted = true
                    }
                  }
                }
                Text {
                  visible: root.searching
                  text: "\uF021"
                  color: Color.accent
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  Layout.alignment: Qt.AlignVCenter
                  RotationAnimation on rotation { running: root.searching; loops: Animation.Infinite; duration: 900; from: 0; to: 360 }
                }
              }
            }

            // status whisper
            Text {
              visible: root.status !== ""
              Layout.fillWidth: true
              text: root.status
              color: Color.muted
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              elide: Text.ElideRight
              maximumLineCount: 1
            }

            // toolbar: scope chips (left) · option chips (right)
            RowLayout {
              Layout.fillWidth: true
              spacing: Style.space(6)
              Repeater {
                model: [
                  { key: "home", label: "~" },
                  { key: "r2d2", label: "r2-d2" },
                  { key: "config", label: ".config" }
                ]
                delegate: Rectangle {
                  required property var modelData
                  readonly property bool on: !root.explicitScope && root.scopeKey === modelData.key
                  Layout.preferredHeight: Style.space(24)
                  Layout.preferredWidth: scopeTxt.implicitWidth + Style.space(20)
                  radius: Style.space(12)
                  color: on ? Util.alpha(Color.accent, 0.18)
                    : (scopeMa.containsMouse ? Util.alpha(Color.foreground, 0.10) : "transparent")
                  border.width: 1
                  border.color: on ? Util.alpha(Color.accent, 0.4) : Util.alpha(Color.foreground, 0.12)
                  Text {
                    id: scopeTxt
                    anchors.centerIn: parent
                    text: modelData.label
                    color: on ? Color.accent : Color.muted
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    font.weight: Font.DemiBold
                  }
                  MouseArea {
                    id: scopeMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                      root.scopeKey = modelData.key
                      root.hovered = -1
                      root.queueSearch(root.query)
                    }
                  }
                }
              }
              Item { Layout.fillWidth: true }
              Repeater {
                model: [
                  { key: "case", label: "Aa", prop: "caseSensitive" },
                  { key: "regex", label: ".*", prop: "regexMode" }
                ]
                delegate: Rectangle {
                  required property var modelData
                  readonly property bool on: root[modelData.prop]
                  Layout.preferredHeight: Style.space(22)
                  Layout.preferredWidth: Style.space(30)
                  radius: Style.space(11)
                  color: on ? Util.alpha(Color.accent, 0.18)
                    : (optMa.containsMouse ? Util.alpha(Color.foreground, 0.10) : Util.alpha(Color.foreground, 0.05))
                  border.width: 1
                  border.color: on ? Util.alpha(Color.accent, 0.4) : Util.alpha(Color.foreground, 0.12)
                  Text {
                    anchors.centerIn: parent
                    text: modelData.label
                    color: on ? Color.accent : Color.muted
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.bodySmall
                    font.weight: Font.ExtraBold
                  }
                  MouseArea {
                    id: optMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                      root[modelData.prop] = !root[modelData.prop]
                      root.startSearch(root.query)
                      root.startFindFor(root.query)
                    }
                  }
                }
              }
            }

            // results
            ListView {
              Layout.fillWidth: true
              Layout.fillHeight: true
              visible: root.results.length > 0
              clip: true
              spacing: Style.space(6)
              model: root.results
              currentIndex: root.selected
              boundsBehavior: Flickable.StopAtBounds
              ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

              delegate: Rectangle {
                id: rowRoot
                required property var modelData
                required property int index
                readonly property bool active: index === root.selected || index === root.hovered
                readonly property var parts: root.hlParts(modelData.snippet, root.activePattern)
                width: ListView.view.width
                height: Style.space(52)
                radius: Style.cornerRadius
                color: active ? Util.alpha(Color.accent, 0.14) : Util.alpha(Color.foreground, 0.04)
                border.width: 1
                border.color: active ? Util.alpha(Color.accent, 0.35) : Util.alpha(Color.foreground, 0.08)
                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                  anchors.fill: parent
                  anchors.leftMargin: Style.space(12)
                  anchors.rightMargin: Style.space(10)
                  spacing: Style.space(10)

                  ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2
                    RowLayout {
                      Layout.fillWidth: true
                      spacing: Style.space(6)
                      Text {
                        text: (String(modelData.file).split("/").pop() || modelData.file)
                        color: Color.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.bodySmall
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                      }
                      Text {
                        text: ":" + modelData.line
                        color: rowRoot.active ? Color.accent : Color.muted
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        font.weight: Font.Bold
                      }
                      Text {
                        text: {
                          var i = String(modelData.file).lastIndexOf("/")
                          var d = i <= 0 ? "" : root.shortPath(modelData.file.slice(0, i))
                          return d
                        }
                        color: Color.muted
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption - 1
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                      }
                    }
                    RowLayout {
                      visible: modelData.isFile !== true
                      Layout.fillWidth: true
                      spacing: 0
                      Text {
                        text: rowRoot.parts.pre
                        color: Color.muted
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption - 1
                        elide: Text.ElideRight
                        maximumLineCount: 1
                      }
                      Text {
                        text: rowRoot.parts.hit
                        visible: rowRoot.parts.hit !== ""
                        color: Color.accent
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption - 1
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                        maximumLineCount: 1
                      }
                      Text {
                        text: rowRoot.parts.post
                        color: Color.muted
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption - 1
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        Layout.fillWidth: true
                      }
                    }
                  }
                  Rectangle {
                    visible: modelData.isFile === true
                    Layout.preferredWidth: Style.space(38)
                    Layout.preferredHeight: Style.space(18)
                    radius: Style.space(9)
                    color: Util.alpha(Color.accent, 0.16)
                    border.width: 1
                    border.color: Util.alpha(Color.accent, 0.4)
                    Text {
                      anchors.centerIn: parent
                      text: "FILE"
                      color: Color.accent
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.caption - 3
                      font.weight: Font.Bold
                      font.letterSpacing: 1
                    }
                    Layout.alignment: Qt.AlignVCenter
                  }
                }
                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  onEntered: root.hovered = index
                  onExited: root.hovered = -1
                  onClicked: root.openResult(modelData)
                }
              }
            }

            // empty state
            Item {
              Layout.fillWidth: true
              Layout.fillHeight: true
              visible: root.results.length === 0
              Text {
                anchors.centerIn: parent
                text: "Type at least 2 characters"
                color: Color.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }
            }

            // footer kbd hints
            Row {
              Layout.alignment: Qt.AlignHCenter
              spacing: Style.space(12)
              Repeater {
                model: [
                  { k: "↵", a: "open in cursor" },
                  { k: "^Y", a: "copy" },
                  { k: "^U", a: "clear" },
                  { k: "esc", a: "clear/close" }
                ]
                delegate: Row {
                  required property var modelData
                  spacing: 4
                  Rectangle {
                    width: kbdTxt.implicitWidth + Style.space(10)
                    height: Style.space(16)
                    radius: 4
                    color: Util.alpha(Color.foreground, 0.08)
                    border.width: 1
                    border.color: Util.alpha(Color.foreground, 0.12)
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                      id: kbdTxt
                      anchors.centerIn: parent
                      text: modelData.k
                      color: Color.accent
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.caption - 3
                      font.weight: Font.Bold
                    }
                  }
                  Text {
                    text: modelData.a
                    color: Color.muted
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption - 3
                    font.weight: Font.Bold
                    font.letterSpacing: 1.3
                    anchors.verticalCenter: parent.verticalCenter
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
