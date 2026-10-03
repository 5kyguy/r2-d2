import QtQuick
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "r2-d2.cpu"

  property string label: "󰍛 --%"
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.label
    tooltipText: "CPU"
    horizontalMargin: 6
    onPressed: function() {
      if (root.bar) root.bar.run("r2-d2-launch-tui btop")
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
}
