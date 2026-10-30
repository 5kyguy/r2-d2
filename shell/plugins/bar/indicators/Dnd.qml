import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property bool dnd: false

  readonly property string dndPath: {
    var state = Quickshell.env("XDG_STATE_HOME")
    if (!state) state = Quickshell.env("HOME") + "/.local/state"
    return state + "/den-den-mushi/dnd"
  }

  active: dnd
  activeText: "󰂛"
  inactiveText: "󰂛"
  activeTooltipText: "Allow Notifications"
  inactiveTooltipText: "Silence Notifications"

  function applyDnd(raw) {
    var text = String(raw || "").trim().toLowerCase()
    root.dnd = text === "1" || text === "on" || text === "true"
  }

  FileView {
    id: dndFile
    path: root.dndPath
    watchChanges: true
    printErrors: false
    onLoaded: root.applyDnd(text())
    onFileChanged: reload()
    onLoadFailed: root.dnd = false
  }

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { dndFile.reload() }
  }

  onPressed: function() {
    if (root.bar) root.bar.run("r2-d2-toggle-notification-silencing")
  }
}
