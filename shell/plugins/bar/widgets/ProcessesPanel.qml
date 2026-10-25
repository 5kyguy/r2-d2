import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// The process list popup, shared by the three stats widgets (CPU, Memory,
// Temperature). Each widget loads one copy of this file and anchors it under
// its own button, so the list opens where the click happened; the popout
// coordinator keeps only one of them on screen at a time.
//
// A click on a bar stat used to drop into a btop terminal. This is the
// first-class version: every running process in a plain list, busiest first,
// with a kill button at the left edge of each row where the eye lands first
// when scanning for the row to act on. The button sends SIGTERM — the same
// signal a terminal Ctrl-C sends — and the next refresh (not the click) is
// what removes the row, so a graceful shutdown is allowed to finish rather
// than being declared over by the UI.
//
// Keyboard: j/k (or arrows) move a cursor, Enter or x kills the row under
// it, Escape closes. Hovering a row moves the cursor too, mouse and keyboard
// share one highlight.
Item {
  id: root

  // The stats widget hosting this panel (a qs.Ui Panel): owns the
  // open/close lifecycle and the bar identity the popout coordinator uses.
  property var owner: null
  property var bar: null
  property var anchorItem: null

  ListModel {
    id: processModel
  }

  property string killHint: ""
  property int cursorIndex: -1
  property bool cursorActive: false

  function refresh() {
    if (!psProbe.running) psProbe.running = true
  }

  // ps columns: pid user pcpu pmem comm. comm is last so a name with spaces
  // in it stays one name. The list is capped at the busiest hundred — a
  // full ps on a desktop is several hundred rows, nearly all of them idle
  // kernel threads nobody scrolls to.
  function applyProcesses(raw) {
    var lines = String(raw).split("\n")
    processModel.clear()
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (line === "") continue
      var parts = line.split(/\s+/)
      if (parts.length < 5) continue
      processModel.append({
        pid: parts[0],
        user: parts[1],
        cpu: parseFloat(parts[2]),
        mem: parseFloat(parts[3]),
        name: parts.slice(4).join(" ")
      })
    }
    if (cursorIndex > processModel.count - 1) cursorIndex = processModel.count - 1
  }

  function killProcess(pid, name) {
    if (killProc.running) return
    killProc.targetPid = String(pid)
    killProc.targetName = String(name)
    killProc.command = ["kill", String(pid)]
    killProc.running = true
  }

  function killCursor() {
    if (!cursorActive || cursorIndex < 0 || cursorIndex > processModel.count - 1) return
    var row = processModel.get(cursorIndex)
    if (row) killProcess(row.pid, row.name)
  }

  function moveCursor(delta) {
    if (processModel.count === 0) return
    if (!cursorActive) {
      cursorActive = true
      cursorIndex = 0
      return
    }
    var next = cursorIndex + delta
    if (next < 0) next = 0
    if (next > processModel.count - 1) next = processModel.count - 1
    cursorIndex = next
  }

  // Rows call this when the keyboard cursor lands on them, so j/k walks the
  // list inside the viewport rather than off it (same job as the audio
  // panel's ensureCursorVisible).
  function ensureCursorVisible(item) {
    if (!item || !scrollArea) return
    var flick = scrollArea.contentItem
    if (!flick || flick.contentY === undefined) return
    var margin = 6
    var maxY = Math.max(0, (flick.contentHeight || 0) - flick.height)
    if (maxY <= Style.space(24)) {
      flick.contentY = 0
      return
    }
    var pt = item.mapToItem(flick.contentItem || flick, 0, 0)
    var top = pt.y
    var bottom = top + (item.height || 0)
    var viewTop = flick.contentY
    var viewBottom = viewTop + flick.height
    if (top < viewTop + margin) flick.contentY = Math.max(0, Math.min(maxY, top - margin))
    else if (bottom > viewBottom - margin)
      flick.contentY = Math.max(0, Math.min(maxY, bottom + margin - flick.height))
  }

  readonly property color rowHoverFill: bar
    ? Style.hoverFillFor(bar.foreground, Colors.accent)
    : "transparent"

  implicitWidth: 0
  implicitHeight: 0

  Process {
    id: psProbe
    command: ["bash", "-c", "ps -eo pid:7,user:12,pcpu:5,pmem:4,comm --sort=-pcpu --no-headers | head -100"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyProcesses(text)
    }
  }

  Process {
    id: killProc
    property string targetPid: ""
    property string targetName: ""
    stderr: StdioCollector {
      waitForEnd: true
    }
    onExited: function(code, status) {
      // kill(1) exits non-zero for processes that are not ours (EPERM) or
      // already gone; say so instead of leaving a button that seemed to do
      // nothing. Success stays quiet — the row leaving the list is the
      // confirmation.
      root.killHint = code === 0
        ? ""
        : "Couldn't kill " + killProc.targetName + " (" + killProc.targetPid + ")"
      refreshSoon.restart()
    }
  }

  // Polls only while a copy of this panel is open; the timer's start is the
  // refresh, so opening the popup always shows a current list.
  Timer {
    interval: 2000
    running: root.owner && root.owner.opened
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  // A kill is followed by its own quick refresh rather than waiting out the
  // poll: SIGTERM usually lands well inside two seconds.
  Timer {
    id: refreshSoon
    interval: 350
    onTriggered: root.refresh()
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.owner
    bar: root.bar
    open: root.owner && root.owner.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(480))
    contentHeight: panel.fittedContentHeight(panelColumn.implicitHeight, Style.space(560))

    onOpenChanged: if (!open) {
      root.cursorActive = false
      root.cursorIndex = -1
      root.killHint = ""
    }

    PanelKeyCatcher {
      id: keyCatcher
      onMoveRequested: function(dx, dy) {
        if (dy !== 0) root.moveCursor(dy)
      }
      onActivateRequested: if (root.cursorActive) root.killCursor()
      onCloseRequested: if (root.owner) root.owner.close()
      onTabRequested: function(direction) { if (root.owner) root.owner.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "x" || t === "X") root.killCursor()
      }

      ScrollView {
        id: scrollArea
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: panelColumn.implicitHeight > height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        Binding {
          target: scrollArea.contentItem
          property: "interactive"
          value: panelColumn.implicitHeight > scrollArea.height
        }

        Column {
          id: panelColumn
          width: scrollArea.availableWidth
          spacing: Style.space(12)

          // ---------- Hero ----------
          Item {
            width: parent.width
            implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight)

            Text {
              id: heroIcon
              text: "󰍛"
              color: root.bar ? root.bar.foreground : Colors.foreground
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.display
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
            }

            Column {
              id: heroLabels
              anchors.left: heroIcon.right
              anchors.leftMargin: Style.space(14)
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(2)

              Text {
                text: "Processes"
                color: root.bar ? root.bar.foreground : Colors.foreground
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.title
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
              }

              Text {
                textFormat: Text.PlainText
                text: (root.killHint !== ""
                  ? root.killHint
                  : processModel.count + " SHOWN · BUSIEST FIRST").toUpperCase()
                color: root.killHint !== "" ? Colors.urgent : Qt.darker(root.bar ? root.bar.foreground : Colors.foreground, 1.4)
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1.2
                elide: Text.ElideRight
                width: parent.width
              }
            }
          }

          PanelSeparator {
            foreground: root.bar ? root.bar.foreground : Colors.foreground
          }

          // ---------- Column headings, aligned with the rows below ----------
          Row {
            width: parent.width
            leftPadding: Style.space(6)
            rightPadding: Style.space(6)
            spacing: Style.space(10)

            Item {
              width: killSlotWidth
              height: Style.space(14)
            }

            Text {
              text: "PROCESS"
              color: Qt.darker(root.bar ? root.bar.foreground : Colors.foreground, 1.5)
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.caption
              font.letterSpacing: 1
              font.bold: true
              width: parent.width - killSlotWidth - userColWidth - cpuColWidth - memColWidth - parent.spacing * 3
              elide: Text.ElideRight
            }

            Text {
              text: "USER"
              color: Qt.darker(root.bar ? root.bar.foreground : Colors.foreground, 1.5)
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.caption
              font.letterSpacing: 1
              font.bold: true
              width: userColWidth
              elide: Text.ElideRight
            }

            Text {
              text: "CPU"
              color: Qt.darker(root.bar ? root.bar.foreground : Colors.foreground, 1.5)
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.caption
              font.letterSpacing: 1
              font.bold: true
              width: cpuColWidth
              horizontalAlignment: Text.AlignRight
            }

            Text {
              text: "MEM"
              color: Qt.darker(root.bar ? root.bar.foreground : Colors.foreground, 1.5)
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.caption
              font.letterSpacing: 1
              font.bold: true
              width: memColWidth
              horizontalAlignment: Text.AlignRight
            }
          }

          Repeater {
            model: processModel

            ProcessRow {
              width: panelColumn.width
            }
          }
        }
      }
    }
  }

  // Shared column metrics so the headings and every row line up without a
  // layout engine: the kill button slot, then fixed user/cpu/mem columns,
  // and the name takes whatever is left.
  readonly property real killSlotWidth: Style.space(28)
  readonly property real userColWidth: Style.space(96)
  readonly property real cpuColWidth: Style.space(52)
  readonly property real memColWidth: Style.space(52)

  // One process row: kill button at the left edge, then name with pid, user,
  // cpu and mem. The highlight comes from hasCursor only — hover moves the
  // same cursor the keyboard moves, so there is exactly one highlight.
  component ProcessRow: CursorSurface {
    id: processRow
    // ListModel roles arrive as required properties; index is the list
    // position the shared cursor addresses.
    required property int index
    required property var pid
    required property var user
    required property var cpu
    required property var mem
    required property var name

    hasCursor: root.cursorActive && root.cursorIndex === index
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(processRow)
    foreground: root.bar ? root.bar.foreground : Colors.foreground
    fill: root.rowHoverFill
    implicitHeight: rowInner.implicitHeight + Style.spacing.xl

    Row {
      id: rowInner
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(6)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(10)

      PanelActionButton {
        id: killButton
        anchors.verticalCenter: parent.verticalCenter
        iconText: "󰅖"
        tooltipText: "Kill " + processRow.name + " (" + processRow.pid + ")"
        foreground: root.bar ? root.bar.foreground : Colors.foreground
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        width: root.killSlotWidth
        height: root.killSlotWidth
        onClicked: root.killProcess(processRow.pid, processRow.name)
      }

      Text {
        textFormat: Text.PlainText
        anchors.verticalCenter: parent.verticalCenter
        text: processRow.name + " · " + processRow.pid
        color: root.bar ? root.bar.foreground : Colors.foreground
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body
        elide: Text.ElideRight
        // Name takes the row width minus the fixed columns.
        width: parent.width - root.killSlotWidth - root.userColWidth - root.cpuColWidth - root.memColWidth - parent.spacing * 3
      }

      Text {
        textFormat: Text.PlainText
        anchors.verticalCenter: parent.verticalCenter
        text: processRow.user
        color: Qt.darker(root.bar ? root.bar.foreground : Colors.foreground, 1.5)
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
        width: root.userColWidth
      }

      Text {
        textFormat: Text.PlainText
        anchors.verticalCenter: parent.verticalCenter
        text: processRow.cpu.toFixed(1) + "%"
        color: Qt.darker(root.bar ? root.bar.foreground : Colors.foreground, 1.5)
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.caption
        font.bold: true
        width: root.cpuColWidth
        horizontalAlignment: Text.AlignRight
      }

      Text {
        textFormat: Text.PlainText
        anchors.verticalCenter: parent.verticalCenter
        text: processRow.mem.toFixed(1) + "%"
        color: Qt.darker(root.bar ? root.bar.foreground : Colors.foreground, 1.5)
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.caption
        font.bold: true
        width: root.memColWidth
        horizontalAlignment: Text.AlignRight
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.NoButton
      onContainsMouseChanged: if (containsMouse) {
        root.cursorActive = true
        root.cursorIndex = processRow.index
      }
    }
  }
}
