import QtQuick
import Quickshell
import Quickshell.Services.SystemStats
import qs.Ui

BarWidget {
  id: root
  moduleName: "henry.cpu-catjam"

  implicitWidth: catjamImage.implicitWidth + Style.space(8)
  implicitHeight: catjamImage.implicitHeight + Style.space(4)

  // CPU usage monitor
  CpuUsage {
    id: cpuMonitor
    updateInterval: 500  // Update every 500ms
  }

  // Calculate animation speed based on CPU usage
  // Low CPU (0-20%): slow (2000ms per frame)
  // Medium CPU (20-60%): medium (1000ms per frame)
  // High CPU (60-100%): fast (300ms per frame)
  property real cpuPercent: cpuMonitor.usage * 100
  property int frameInterval: {
    if (cpuPercent < 20) return 2000
    if (cpuPercent < 60) return 1000 - (cpuPercent - 20) * 17.5  // Gradually speed up
    return Math.max(100, 1000 - (cpuPercent - 20) * 17.5)  // Cap at 100ms minimum
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
