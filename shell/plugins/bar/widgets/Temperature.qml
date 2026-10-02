import QtQuick
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "r2-d2.temperature"

  property string label: "--°C"
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.label
    tooltipText: "Temperature"
    horizontalMargin: 6
    onPressed: function() {
      if (root.bar) root.bar.run("r2-d2-launch-tui btop")
    }
  }

  Process {
    id: probe
    command: ["bash", "-c", "for z in /sys/class/thermal/thermal_zone*/temp; do t=$(<\"$z\") || continue; if (( t > 1000 && t < 150000 )); then echo $((t / 1000)); exit 0; fi; done; echo --"]
    stdout: SplitParser {
      onRead: function(line) { root.label = String(line).trim() + "°C" }
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
