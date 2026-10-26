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
    command: ["r2-d2-cpu-temp"]
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
