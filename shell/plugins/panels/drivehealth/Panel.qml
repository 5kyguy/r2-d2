import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Drive health panel. Lists whole disks with model, transport, size,
// temperature (NVMe hwmon sysfs), and best-effort SMART status, then each
// mountpoint with a usage bar and a "Test" button that runs
// r2-d2-drive-speedtest against that mount and shows write/read MB/s inline.
//
// Standalone panel plugin summoned with `r2-d2-shell shell toggle r2-d2.drivehealth`.
// Data comes from r2-d2-drive-health (JSON) on open.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property var disks: []
  // mount -> { write_mbps, read_mbps, error, running }
  property var speed: ({})
  property string testingMount: ""
  property string fontFamily: Style.font.family

  function open(payloadJson) {
    root.opened = true
    fetchHealth()
    Qt.callLater(function() {
      if (root.opened) keyCatcher.forceActiveFocus()
    })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "r2-d2.drivehealth")
    else close()
  }

  function fetchHealth() {
    healthProc.command = ["r2-d2-drive-health"]
    healthProc.running = true
  }

  function applyHealth(text) {
    var j = null
    try { j = JSON.parse(text) } catch (e) { j = null }
    root.disks = (j && j.disks) ? j.disks : []
  }

  function runTest(mount) {
    var s = Object.assign({}, root.speed)
    s[mount] = { write_mbps: 0, read_mbps: 0, error: "", running: true }
    root.speed = s
    root.testingMount = mount
    speedProc.command = ["r2-d2-drive-speedtest", mount, "128"]
    speedProc.running = true
  }

  function applyTest(text) {
    var mount = root.testingMount
    root.testingMount = ""
    if (!mount) return
    var j = null
    try { j = JSON.parse(text) } catch (e) { j = null }
    var s = Object.assign({}, root.speed)
    if (j) {
      s[mount] = {
        write_mbps: j.write_mbps || 0,
        read_mbps: j.read_mbps || 0,
        error: j.error || "",
        running: false
      }
    } else {
      s[mount] = { write_mbps: 0, read_mbps: 0, error: "no output", running: false }
    }
    root.speed = s
  }

  function fmtBytes(b) {
    if (!b || b <= 0) return "0"
    var units = ["B", "KB", "MB", "GB", "TB", "PB"]
    var i = 0
    var v = b
    while (v >= 1024 && i < units.length - 1) { v /= 1024; i += 1 }
    return (Math.round(v * 10) / 10) + " " + units[i]
  }

  function smartText(s) {
    if (s === "PASSED") return "SMART OK"
    if (s === "FAILED") return "SMART FAIL"
    return "SMART —"
  }

  function smartColor(s) {
    if (s === "PASSED") return Color.accent
    if (s === "FAILED") return Color.urgent
    return Color.muted
  }

  Process {
    id: healthProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyHealth(String(text || ""))
    }
  }

  Process {
    id: speedProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyTest(String(text || ""))
    }
  }

  PanelWindow {
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "r2-d2-drivehealth"
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
          width: Math.min(Style.space(560), keyCatcher.width - Style.space(48))
          height: content.implicitHeight + Style.space(28)
          radius: Style.cornerRadius
          color: Color.popups.background
          border.width: 1
          border.color: Color.popups.border

          ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Style.space(14)
            spacing: Style.space(10)

            // header
            RowLayout {
              Layout.fillWidth: true
              Text {
                text: "DRIVE HEALTH"
                color: Color.accent
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
                font.weight: Font.ExtraBold
                font.letterSpacing: 1.4
                Layout.fillWidth: true
              }
              Text {
                text: root.disks.length + " disk" + (root.disks.length === 1 ? "" : "s")
                color: Color.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }
            }

            // empty state
            Item {
              visible: root.disks.length === 0
              Layout.fillWidth: true
              Layout.preferredHeight: Style.space(60)
              Text {
                anchors.centerIn: parent
                text: "No disks found"
                color: Color.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }
            }

            // disks
            Repeater {
              model: root.disks
              delegate: ColumnLayout {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                spacing: Style.space(6)

                Rectangle {
                  Layout.fillWidth: true
                  Layout.preferredHeight: 1
                  color: Util.alpha(Color.foreground, 0.1)
                  visible: index > 0
                }

                // disk header row
                RowLayout {
                  Layout.fillWidth: true
                  spacing: Style.space(8)
                  Text {
                    text: modelData.name
                    color: Color.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                    font.weight: Font.Bold
                  }
                  Text {
                    text: modelData.model || ""
                    color: Color.muted
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                  }
                  Text {
                    text: (modelData.tran || "disk").toUpperCase()
                    color: Color.muted
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                  }
                  Text {
                    text: root.fmtBytes(modelData.size)
                    color: Color.muted
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                  }
                  Text {
                    visible: modelData.temp_c !== null && modelData.temp_c !== undefined
                    text: modelData.temp_c + "°C"
                    color: (modelData.temp_c || 0) >= 60 ? Color.urgent : Color.muted
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                  }
                  Text {
                    text: root.smartText(modelData.smart)
                    color: root.smartColor(modelData.smart)
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    font.weight: Font.Bold
                  }
                }

                // partitions
                Repeater {
                  model: modelData.partitions
                  delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.leftMargin: Style.space(8)
                    spacing: Style.space(4)

                    RowLayout {
                      Layout.fillWidth: true
                      spacing: Style.space(8)
                      Text {
                        text: modelData.mount
                        color: Color.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.bodySmall
                        Layout.preferredWidth: Style.space(180)
                        elide: Text.ElideRight
                      }
                      Text {
                        text: modelData.fstype || ""
                        color: Color.muted
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        Layout.preferredWidth: Style.space(48)
                      }
                      Text {
                        text: modelData.use_pct + "%"
                        color: modelData.use_pct >= 90 ? Color.urgent
                          : (modelData.use_pct >= 75 ? Color.accent : Color.muted)
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        Layout.preferredWidth: Style.space(36)
                        horizontalAlignment: Text.AlignRight
                      }
                      Text {
                        text: root.fmtBytes(modelData.used) + " / " + root.fmtBytes(modelData.size)
                        color: Color.muted
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                      }
                    }

                    // btrfs subvolumes sharing this filesystem (collapsed into one row)
                    Text {
                      Layout.fillWidth: true
                      Layout.leftMargin: Style.space(180)
                      visible: (modelData.mounts || []).length > 1
                      text: "subvolumes  " + (modelData.mounts || [])
                        .filter(function(m) { return m !== modelData.mount })
                        .join("    ")
                      color: Color.muted
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.caption
                      elide: Text.ElideRight
                    }

                    // usage bar
                    Rectangle {
                      Layout.fillWidth: true
                      Layout.preferredHeight: Style.space(6)
                      radius: 3
                      color: Util.alpha(Color.foreground, 0.08)
                      Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * Math.min(1, modelData.use_pct / 100)
                        radius: 3
                        color: modelData.use_pct >= 90 ? Color.urgent
                          : (modelData.use_pct >= 75 ? Color.accent
                             : Util.alpha(Color.accent, 0.7))
                      }
                    }

                    // test row
                    RowLayout {
                      Layout.fillWidth: true
                      spacing: Style.space(8)
                      Rectangle {
                        Layout.preferredWidth: Style.space(64)
                        Layout.preferredHeight: Style.space(28)
                        radius: Style.cornerRadius
                        color: testMa.containsMouse
                          ? Util.alpha(Color.accent, 0.22)
                          : Util.alpha(Color.accent, 0.12)
                        border.width: 1
                        border.color: Util.alpha(Color.accent, 0.4)
                        Text {
                          anchors.centerIn: parent
                          text: (root.speed[modelData.mount] && root.speed[modelData.mount].running)
                            ? "..." : "Test"
                          color: Color.accent
                          font.family: root.fontFamily
                          font.pixelSize: Style.font.caption
                          font.weight: Font.Bold
                        }
                        MouseArea {
                          id: testMa
                          anchors.fill: parent
                          hoverEnabled: true
                          onClicked: root.runTest(modelData.mount)
                        }
                      }
                      Text {
                        visible: !root.speed[modelData.mount]
                        text: "Run a write/read speed test"
                        color: Color.muted
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        Layout.fillWidth: true
                      }
                      Text {
                        visible: root.speed[modelData.mount] && root.speed[modelData.mount].running
                        text: "Testing " + modelData.mount + " ..."
                        color: Color.muted
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        Layout.fillWidth: true
                      }
                      Text {
                        visible: root.speed[modelData.mount] && !root.speed[modelData.mount].running
                          && !root.speed[modelData.mount].error
                        text: "W " + root.speed[modelData.mount].write_mbps
                          + " · R " + root.speed[modelData.mount].read_mbps + " MB/s"
                        color: Color.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                      }
                      Text {
                        visible: root.speed[modelData.mount] && !root.speed[modelData.mount].running
                          && root.speed[modelData.mount].error
                        text: root.speed[modelData.mount].error
                        color: Color.urgent
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        Layout.fillWidth: true
                        elide: Text.ElideRight
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
  }
}
