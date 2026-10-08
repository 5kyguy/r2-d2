import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Screen Time panel: a 7-day x 24-hour usage heatmap plus today's top apps.
//
// Standalone panel plugin. Data comes from the r2-d2-screentime sampler:
//   r2-d2-screentime --export all   -> { heatmap[7][24], days[], total_secs, today_secs }
//   r2-d2-screentime --export today -> { apps[{name, secs}], total_secs }
// Both are fetched on open. Idle time is not counted, so the grid shows when
// apps were actually focused, not wall-clock uptime.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property var heatRows: []      // 7 x 24 seconds
  property var dayLabels: []     // [{label, secs, is_today}]
  property var todayApps: []     // [{name, secs}]
  property int todaySecs: 0
  property int totalSecs: 0
  property int maxCell: 1        // peak cell seconds, for heat scaling
  property string fontFamily: Style.font.family

  function open(payloadJson) {
    root.opened = true
    fetchAll()
    fetchToday()
    Qt.callLater(function() {
      if (root.opened) keyCatcher.forceActiveFocus()
    })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "r2-d2.screentime")
    else close()
  }

  function fetchAll() {
    allProc.command = ["r2-d2-screentime", "--export", "all"]
    allProc.running = true
  }

  function fetchToday() {
    todayProc.command = ["r2-d2-screentime", "--export", "today"]
    todayProc.running = true
  }

  function applyAll(text) {
    var j = null
    try { j = JSON.parse(text) } catch (e) { j = null }
    if (!j) { root.heatRows = []; root.dayLabels = []; root.totalSecs = 0; root.todaySecs = 0; return }
    root.heatRows = j.heatmap || []
    root.dayLabels = j.days || []
    root.totalSecs = j.total_secs || 0
    root.todaySecs = j.today_secs || 0
    var mx = 1
    for (var d = 0; d < root.heatRows.length; d++) {
      var row = root.heatRows[d]
      for (var h = 0; h < row.length; h++) if (row[h] > mx) mx = row[h]
    }
    root.maxCell = mx
  }

  function applyToday(text) {
    var j = null
    try { j = JSON.parse(text) } catch (e) { j = null }
    if (!j) { root.todayApps = []; return }
    root.todayApps = (j.apps || []).slice(0, 8)
  }

  function fmtDur(secs) {
    if (secs <= 0) return "No activity"
    var m = Math.floor(secs / 60)
    if (m < 60) return m + " min"
    var h = Math.floor(m / 60)
    var rm = m % 60
    return rm === 0 ? (h + "h") : (h + "h " + rm + "m")
  }

  Process {
    id: allProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyAll(String(text || ""))
    }
  }

  Process {
    id: todayProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyToday(String(text || ""))
    }
  }

  PanelWindow {
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "r2-d2-screentime"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle {
      anchors.fill: parent
      color: Colors.menu.scrim
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
          width: Math.min(Style.space(520), keyCatcher.width - Style.space(48))
          height: content.implicitHeight + Style.space(28)
          radius: Style.cornerRadius
          color: Colors.popups.background
          border.width: 1
          border.color: Colors.popups.border

          ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Style.space(14)
            spacing: Style.space(10)

            // header
            RowLayout {
              Layout.fillWidth: true
              Text {
                text: "SCREEN TIME"
                color: Colors.accent
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
                font.weight: Font.ExtraBold
                font.letterSpacing: 1.4
                Layout.fillWidth: true
              }
              Text {
                text: root.fmtDur(root.todaySecs) + " today"
                color: Colors.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }
            }

            // heatmap: 7 rows x 24 cols
            ColumnLayout {
              Layout.fillWidth: true
              spacing: Style.space(3)
              Repeater {
                model: root.heatRows.length
                delegate: RowLayout {
                  required property int index
                  Layout.fillWidth: true
                  spacing: Style.space(6)
                  Text {
                    text: (root.dayLabels[index] || {}).label || ""
                    color: ((root.dayLabels[index] || {}).is_today) ? Colors.accent : Colors.muted
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    Layout.preferredWidth: Style.space(28)
                  }
                  Repeater {
                    model: root.heatRows[index] || []
                    delegate: Rectangle {
                      required property int index
                      required property var modelData
                      Layout.fillWidth: true
                      Layout.preferredHeight: Style.space(14)
                      radius: 2
                      color: Util.alpha(Colors.accent, Math.min(1, modelData / root.maxCell))
                      border.width: 1
                      border.color: Util.alpha(Colors.foreground, modelData > 0 ? 0.05 : 0.02)
                    }
                  }
                }
              }
            }

            // hour axis
            RowLayout {
              Layout.fillWidth: true
              Layout.leftMargin: Style.space(34)
              spacing: 0
              Repeater {
                model: [0, 6, 12, 18]
                delegate: Item {
                  required property int index
                  Layout.fillWidth: true
                  Text {
                    anchors.left: parent.left
                    text: ["00", "06", "12", "18"][index]
                    color: Colors.muted
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption - 2
                  }
                }
              }
            }

            // week totals row
            RowLayout {
              Layout.fillWidth: true
              spacing: Style.space(6)
              Text {
                text: "7d"
                color: Colors.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                Layout.preferredWidth: Style.space(28)
              }
              Text {
                text: root.fmtDur(root.totalSecs) + " total"
                color: Colors.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                Layout.fillWidth: true
              }
            }

            Rectangle {
              Layout.fillWidth: true
              height: 1
              color: Util.alpha(Colors.foreground, 0.1)
            }

            // top apps today
            Text {
              text: "TOP APPS TODAY"
              color: Colors.muted
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.weight: Font.Bold
              font.letterSpacing: 1.3
            }

            Repeater {
              model: root.todayApps
              delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: Style.space(8)
                Text {
                  text: modelData.name
                  color: Colors.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  Layout.preferredWidth: Style.space(140)
                  elide: Text.ElideRight
                }
                Rectangle {
                  Layout.fillWidth: true
                  Layout.preferredHeight: Style.space(8)
                  radius: 3
                  color: Util.alpha(Colors.accent, 0.12)
                  Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.min(1, modelData.secs / Math.max(1, root.todayApps.length ? root.todayApps[0].secs : 1))
                    color: Colors.accent
                    radius: 3
                  }
                }
                Text {
                  text: root.fmtDur(modelData.secs)
                  color: Colors.muted
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  Layout.preferredWidth: Style.space(52)
                  horizontalAlignment: Text.AlignRight
                }
              }
            }

            Item {
              visible: root.todayApps.length === 0
              Layout.fillWidth: true
              Layout.preferredHeight: Style.space(40)
              Text {
                anchors.centerIn: parent
                text: "No focused-app samples yet"
                color: Colors.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }
            }
          }
        }
      }
    }
  }
}
