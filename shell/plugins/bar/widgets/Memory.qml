import QtQuick
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "r2-d2.memory"

  property string label: "  --%"
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.label
    tooltipText: "Memory"
    horizontalMargin: 6
    onPressed: function() {
      if (root.bar) root.bar.run("r2-d2-launch-tui btop")
    }
  }

  Process {
    id: probe
    command: ["bash", "-c", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{if (t>0) printf \"%d\", (t-a)*100/t; else print 0}' /proc/meminfo"]
    stdout: SplitParser {
      onRead: function(line) { root.label = "  " + String(line).trim() + "%" }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!probe.running) probe.running = true
  }
}
