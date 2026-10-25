import QtQuick
import Quickshell.Io
import qs.Ui

// Temperature for the bar. Click opens the shared process list
// (ProcessesPanel.qml) anchored under this widget — CPU and Memory host
// the same panel — instead of dropping into a btop terminal.
Panel {
  id: root
  moduleName: "r2-d2.temperature"
  ipcTarget: "r2-d2.temperature"

  property string label: "--°C"
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
    tooltipText: "Temperature"
    horizontalMargin: 6
    onPressed: function() {
      root.toggle()
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
