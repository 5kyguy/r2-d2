import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "r2-d2.logo"

  property string version: ""
  readonly property string versionFile: {
    var base = bar && bar.omarchyPath ? bar.omarchyPath : Quickshell.env("R2D2_PATH")
    return base ? base + "/version" : ""
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function readVersion() {
    if (versionFile === "" || version !== "" || versionProbe.running) return
    versionProbe.running = true
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\ue900"
    fontFamily: "r2d2"
    tooltipText: root.version !== "" ? "R2-D2 v" + root.version : "R2-D2"
    horizontalMargin: 7.5
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("r2-d2-menu")
    }
  }

  Process {
    id: versionProbe
    command: ["cat", root.versionFile]
    stdout: SplitParser {
      onRead: function(line) {
        var text = String(line).trim()
        if (text.length > 0) root.version = text
      }
    }
  }

  Component.onCompleted: root.readVersion()
  onVersionFileChanged: root.readVersion()
}
