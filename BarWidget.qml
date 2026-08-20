import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "henry.cpu-catjam"

  implicitWidth: catjamImage.implicitWidth + Style.space(8)
  implicitHeight: catjamImage.implicitHeight + Style.space(4)

  property real cpuPercent: 0

  // CPU usage monitor using top command
  Process {
    id: cpuMonitor
    command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'"]
    running: true
    
    onExited: function(exitCode, exitStatus) {
      if (exitCode === 0) {
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

  Rectangle {
    anchors.fill: parent
    color: "transparent"
    
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
      
      ToolTip {
        visible: mouseArea.containsMouse
        text: "CPU: " + cpuPercent.toFixed(1) + "%"
      }
    }

    MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true
    }
  }
}
