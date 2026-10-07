import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Pomodoro focus timer. Three phases — focus (25m), short break (5m), long
// break (15m) — with a session counter that triggers the long break after
// four focus sessions. Phase transitions fire a desktop notification via
// r2-d2-notification-send and auto-advance. State is in-memory only, so a
// shell restart resets the count; the timer itself is not a persistence tool.
//
// Standalone panel plugin summoned with `r2-d2-shell shell toggle r2-d2.pomodoro`.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property string fontFamily: Style.font.family

  // phases: "focus" | "short" | "long"
  property string phase: "focus"
  property int focusMins: 25
  property int shortMins: 5
  property int longMins: 15
  property int sessionsBeforeLong: 4
  property int completedFocus: 0   // focus sessions done in the current set
  property int totalFocus: 0        // all-time focus sessions this shell session
  property int remaining: focusMins * 60
  property bool running: false

  readonly property int phaseTotal: ({
    "focus": focusMins,
    "short": shortMins,
    "long": longMins
  })[phase] * 60

  readonly property string phaseLabel: ({
    "focus": "FOCUS",
    "short": "SHORT BREAK",
    "long": "LONG BREAK"
  })[phase]

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

  function resetPhase() {
    running = false
    remaining = phaseTotal
  }

  function setPhase(p) {
    phase = p
    resetPhase()
  }

  function toggle() {
    running = !running
  }

  function skip() {
    advance(true)
  }

  function advance(fromManual) {
    running = false
    var finished = phase
    if (phase === "focus") {
      completedFocus += 1
      totalFocus += 1
      var next = (completedFocus % sessionsBeforeLong === 0) ? "long" : "short"
      setPhase(next)
    } else {
      if (phase === "long") completedFocus = 0
      setPhase("focus")
    }
    notify(finished, fromManual)
  }

  function notify(finished, fromManual) {
    var title = ({
      "focus": "Focus done — take a break",
      "short": "Short break over — back to focus",
      "long": "Long break over — back to focus"
    })[finished]
    var body = fromManual ? "Skipped to " + phaseLabel.toLowerCase()
      : (finished === "focus" ? "Nice work. Next: " + phaseLabel.toLowerCase()
         : "Next: " + phaseLabel.toLowerCase())
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
    running: root.running && root.opened
    onTriggered: {
      if (root.remaining > 0) root.remaining -= 1
      if (root.remaining <= 0) root.advance(false)
    }
  }

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
          width: Math.min(Style.space(380), keyCatcher.width - Style.space(48))
          height: content.implicitHeight + Style.space(28)
          radius: Style.cornerRadius
          color: Color.popups.background
          border.width: 1
          border.color: Color.popups.border

          ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Style.space(18)
            spacing: Style.space(12)

            Text {
              text: root.phaseLabel
              color: Color.accent
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.weight: Font.ExtraBold
              font.letterSpacing: 1.6
              Layout.alignment: Qt.AlignHCenter
            }

            Text {
              text: root.fmt(root.remaining)
              color: Color.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.space(64)
              font.weight: Font.Bold
              Layout.alignment: Qt.AlignHCenter
            }

            // session dots: filled = focus sessions done this set
            RowLayout {
              Layout.alignment: Qt.AlignHCenter
              spacing: Style.space(6)
              Repeater {
                model: root.sessionsBeforeLong
                delegate: Rectangle {
                  required property int index
                  width: Style.space(10)
                  height: width
                  radius: width / 2
                  color: root.completedFocus > index ? Color.accent
                    : Util.alpha(Color.foreground, 0.15)
                }
              }
            }

            // controls
            RowLayout {
              Layout.fillWidth: true
              Layout.topMargin: Style.space(6)
              spacing: Style.space(8)
              Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.space(38)
                radius: Style.cornerRadius
                color: startMa.containsMouse
                  ? Util.alpha(Color.accent, 0.22)
                  : Util.alpha(Color.accent, 0.14)
                border.width: 1
                border.color: Util.alpha(Color.accent, 0.4)
                Text {
                  anchors.centerIn: parent
                  text: root.running ? "Pause" : "Start"
                  color: Color.accent
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  font.weight: Font.Bold
                }
                MouseArea {
                  id: startMa
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: root.toggle()
                }
              }
              Rectangle {
                Layout.preferredWidth: Style.space(72)
                Layout.preferredHeight: Style.space(38)
                radius: Style.cornerRadius
                color: skipMa.containsMouse
                  ? Util.alpha(Color.foreground, 0.14)
                  : Util.alpha(Color.foreground, 0.06)
                border.width: 1
                border.color: Util.alpha(Color.foreground, 0.2)
                Text {
                  anchors.centerIn: parent
                  text: "Skip"
                  color: Color.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                }
                MouseArea {
                  id: skipMa
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: root.skip()
                }
              }
              Rectangle {
                Layout.preferredWidth: Style.space(72)
                Layout.preferredHeight: Style.space(38)
                radius: Style.cornerRadius
                color: resetMa.containsMouse
                  ? Util.alpha(Color.foreground, 0.14)
                  : Util.alpha(Color.foreground, 0.06)
                border.width: 1
                border.color: Util.alpha(Color.foreground, 0.2)
                Text {
                  anchors.centerIn: parent
                  text: "Reset"
                  color: Color.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                }
                MouseArea {
                  id: resetMa
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: root.resetPhase()
                }
              }
            }

            Text {
              text: root.totalFocus + " focus sessions this shell session"
              color: Color.muted
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              Layout.alignment: Qt.AlignHCenter
            }
          }
        }
      }
    }
  }
}
