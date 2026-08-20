import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "henry.cpu-catjam"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  property real cpuPercent: 0

  // CPU usage monitor using top command
  Process {
    id: cpuMonitor
    command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'"]
    running: true
    
    onExited: function(exitCode, exitStatus) {
      if (exitCode === 0 && stdout) {
        var output = stdout.trim()
        var value = parseFloat(output)
        if (!isNaN(value)) {
          cpuPercent = value
        }
      }
      // Restart after 500ms
      restartTimer.start()
    }
  }

  Timer {
    id: restartTimer
    interval: 500
    repeat: false
    onTriggered: cpuMonitor.running = true
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    tooltipText: "CPU: " + cpuPercent.toFixed(1) + "%"
    
    AnimatedImage {
      id: catjamImage
      anchors.centerIn: parent
      source: Qt.resolvedUrl("catjam.gif")
      width: 24
      height: 24
      fillMode: Image.PreserveAspectFit
      playing: true
      speed: {
        // Adjust playback speed based on CPU
        // 0.5x at 0% CPU, up to 3x at 100% CPU
        return 0.5 + (cpuPercent / 100) * 2.5
      }
    }
  }
}
