import QtQuick
import Quickshell.Io
import qs.Ui

// CPU percent for the bar. Click opens the shared process list
// (ProcessesPanel.qml) anchored under this widget — Memory and Temperature
// host the same panel — instead of dropping into a btop terminal.
Panel {
  id: root
  moduleName: "r2-d2.cpu"
  ipcTarget: "r2-d2.cpu"

  property string label: "󰍛 --%"
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("anchorItem" in target) target.anchorItem = button
    if ("owner" in target) target.owner = root
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.label
    tooltipText: "CPU"
    horizontalMargin: 6
    onPressed: function() {
      root.toggle()
    }
  }

  Process {
    id: probe
    // Sum user through steal only. guest and guest_nice are already inside user
    // and nice, and a bash `read` dumps those leftover columns into the last
    // variable, which awk then tries to open as a file.
    command: ["awk", "BEGIN { while ((getline < \"/proc/stat\") > 0) { if ($1 == \"cpu\") { idle1 = $5; limit = NF < 9 ? NF : 9; for (i = 2; i <= limit; i++) t1 += $i; break } } close(\"/proc/stat\"); system(\"sleep 0.2\"); while ((getline < \"/proc/stat\") > 0) { if ($1 == \"cpu\") { idle2 = $5; limit = NF < 9 ? NF : 9; for (i = 2; i <= limit; i++) t2 += $i; break } } close(\"/proc/stat\"); dt = t2 - t1; if (dt <= 0) dt = 1; printf \"%d\\n\", (dt - (idle2 - idle1)) * 100 / dt }"]
    stdout: SplitParser {
      onRead: function(line) { root.label = "󰍛 " + String(line).trim() + "%" }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!probe.running) probe.running = true
  }

  Loader {
    id: panelLoader
    source: Qt.resolvedUrl("ProcessesPanel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  onBarChanged: injectPanel()
}
