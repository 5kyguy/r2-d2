import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "r2-d2.logo"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\ue900"
    fontFamily: "r2d2"
    tooltipText: "R2-D2"
    horizontalMargin: 7.5
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("r2-d2-menu")
    }
  }
}
