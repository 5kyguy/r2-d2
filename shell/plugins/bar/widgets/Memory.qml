import QtQuick
import Quickshell.Io
import qs.Ui

// Memory percent for the bar. Click opens the shared process list
// (ProcessesPanel.qml) anchored under this widget — CPU and Temperature
// host the same panel — instead of dropping into a btop terminal.
Panel {
  id: root
  moduleName: "r2-d2.memory"
  ipcTarget: "r2-d2.memory"

  property string label: "\uefc5  --%"
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
    tooltipText: "Memory"
    horizontalMargin: 6
    onPressed: function() {
      root.toggle()
    }
  }

  Process {
    id: probe
    command: ["bash", "-c", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{if (t>0) printf \"%d\", (t-a)*100/t; else print 0}' /proc/meminfo"]
    stdout: SplitParser {
      onRead: function(line) { root.label = "\uefc5  " + String(line).trim() + "%" }
    }
  }

  Timer {
    interval: 2000
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
