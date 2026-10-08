import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Pomodoro: 35 minutes of focus, then a 10 minute break, then focus again.
// Click the time to start, click it again to pause. Clicking outside closes
// the card and leaves the countdown in the clock slot. The shell keeps this
// plugin loaded so the ticker survives that close. State is published to
// pomodoro.json for the clock; a shell restart clears it.
//
// Summoned with `r2-d2-shell shell toggle r2-d2.pomodoro`.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property string fontFamily: Style.font.family

  property string phase: "focus"   // focus | break
  property int focusMins: 35
  property int breakMins: 10
  property int sessionsBeforeLong: 4
  property int completedFocus: 0
  property int totalFocus: 0
  property int remaining: focusMins * 60
  property bool running: false
  property bool engaged: false
  property real endsAt: 0

  readonly property string stateDir: {
    var state = Quickshell.env("XDG_STATE_HOME")
    if (!state) state = Quickshell.env("HOME") + "/.local/state"
    return state + "/r2-d2"
  }
  readonly property string statePath: stateDir + "/pomodoro.json"

  readonly property int phaseTotal: (phase === "break" ? breakMins : focusMins) * 60

  readonly property string phaseLabel: phase === "break" ? "BREAK" : "FOCUS"

  readonly property string hint: !engaged ? "Click the time to start"
    : running ? "Click outside — it stays on the clock"
    : "Click the time to resume"

  function open(payloadJson) {
    root.opened = true
    Qt.callLater(function() {
      if (root.opened) keyCatcher.forceActiveFocus()
    })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "r2-d2.pomodoro")
    else close()
  }

  function syncRemaining() {
    if (!running) return
    var left = Math.round((endsAt - Date.now()) / 1000)
    remaining = left > 0 ? left : 0
  }

  function publish() {
    var payload = {
      shown: engaged,
      running: running,
      phase: phase,
      remaining: remaining,
      endsAt: running ? endsAt : 0
    }
    stateFile.setText(JSON.stringify(payload) + "\n")
  }

  function toggle() {
    if (running) {
      syncRemaining()
      running = false
    } else {
      if (remaining <= 0) remaining = phaseTotal
      engaged = true
      running = true
      endsAt = Date.now() + remaining * 1000
    }
    publish()
  }

  function resetPhase() {
    phase = "focus"
    running = false
    engaged = false
    remaining = focusMins * 60
    endsAt = 0
    publish()
  }

  function skip() {
    advance(true)
  }

  function advance(fromManual) {
    var finished = phase
    if (phase === "focus") {
      completedFocus += 1
      totalFocus += 1
      if (completedFocus > sessionsBeforeLong) completedFocus = 1
      phase = "break"
    } else {
      phase = "focus"
    }
    remaining = phaseTotal
    engaged = true
    running = true
    endsAt = Date.now() + remaining * 1000
    publish()
    notify(finished, fromManual)
  }

  function notify(finished, fromManual) {
    var title = finished === "focus" ? "Focus done — take a break" : "Break over — back to focus"
    var body = fromManual ? "Skipped to " + phaseLabel.toLowerCase()
      : (finished === "focus" ? "Nice work. Next: break" : "Next: focus")
    Quickshell.execDetached([
      "r2-d2-notification-send", "--app-name", "Pomodoro", "-u", "normal",
      "-g", "\uF253", title, body
    ])
  }

  function fmt(t) {
    var m = Math.floor(t / 60)
    var s = t % 60
    return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
  }

  Timer {
    id: ticker
    interval: 1000
    repeat: true
    running: root.running
    onTriggered: {
      root.syncRemaining()
      if (root.remaining <= 0) root.advance(false)
    }
  }

  FileView {
    id: stateFile
    path: root.statePath
    printErrors: false
  }

  Process {
    id: mkdirState
    command: ["mkdir", "-p", root.stateDir]
    onExited: root.publish()
  }

  Component.onCompleted: mkdirState.running = true

  PanelWindow {
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "r2-d2-pomodoro"
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
          width: content.implicitWidth + Style.space(28)
          height: content.implicitHeight + Style.space(28)
          radius: Style.cornerRadius
          color: Colors.popups.background
          border.width: 1
          border.color: Colors.popups.border

          ColumnLayout {
            id: content
            x: Style.space(14)
            y: Style.space(14)
            spacing: Style.space(10)

            Text {
              text: root.phaseLabel
              color: Colors.accent
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.weight: Font.ExtraBold
              font.letterSpacing: 1.6
              Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
              Layout.alignment: Qt.AlignHCenter
              spacing: Style.space(10)

              Text {
                id: timeText
                text: root.fmt(root.remaining)
                color: Colors.foreground
                opacity: root.engaged && !root.running ? 0.45 : 1
                font.family: root.fontFamily
                font.pixelSize: Style.space(52)
                font.weight: Font.Bold

                MouseArea {
                  anchors.fill: parent
                  anchors.margins: -Style.space(6)
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.toggle()
                }
              }

              ColumnLayout {
                spacing: Style.space(6)
                Layout.alignment: Qt.AlignVCenter

                Repeater {
                  model: [
                    { label: "Skip", act: "skip" },
                    { label: "Reset", act: "reset" }
                  ]
                  delegate: Rectangle {
                    required property var modelData
                    Layout.preferredWidth: Style.space(64)
                    Layout.preferredHeight: Style.space(32)
                    radius: Style.cornerRadius
                    color: sideMa.containsMouse
                      ? Util.alpha(Colors.foreground, 0.14)
                      : Util.alpha(Colors.foreground, 0.06)
                    border.width: 1
                    border.color: Util.alpha(Colors.foreground, 0.2)
                    Text {
                      anchors.centerIn: parent
                      text: modelData.label
                      color: Colors.foreground
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.bodySmall
                    }
                    MouseArea {
                      id: sideMa
                      anchors.fill: parent
                      hoverEnabled: true
                      onClicked: modelData.act === "skip" ? root.skip() : root.resetPhase()
                    }
                  }
                }
              }
            }

            RowLayout {
              Layout.alignment: Qt.AlignHCenter
              spacing: Style.space(6)
              Repeater {
                model: root.sessionsBeforeLong
                delegate: Rectangle {
                  required property int index
                  width: Style.space(8)
                  height: width
                  radius: width / 2
                  color: root.completedFocus > index ? Colors.accent
                    : Util.alpha(Colors.foreground, 0.15)
                }
              }
            }

            Text {
              text: root.hint
              color: Colors.muted
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              horizontalAlignment: Text.AlignHCenter
              wrapMode: Text.WordWrap
              Layout.maximumWidth: Style.space(210)
              Layout.alignment: Qt.AlignHCenter
            }
          }
        }
      }
    }
  }
}
