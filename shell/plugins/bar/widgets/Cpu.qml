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
    command: ["bash", "-c", "read _ a b c d e f g h < /proc/stat; sleep 0.2; read _ i j k l m n o p < /proc/stat; awk -v a=$a -v b=$b -v c=$c -v d=$d -v e=$e -v f=$f -v g=$g -v h=$h -v i=$i -v j=$j -v k=$k -v l=$l -v m=$m -v n=$n -v o=$o -v p=$p 'BEGIN{t1=a+b+c+d+e+f+g+h; t2=i+j+k+l+m+n+o+p; idle=l-d; dt=t2-t1; if (dt<=0) dt=1; printf \"%d\", (dt-idle)*100/dt}'"]
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
