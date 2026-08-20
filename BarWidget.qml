import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "henry.cpu-catjam"

  implicitWidth: catjamImage.width + 8
  implicitHeight: catjamImage.height + 4

  property real cpuPercent: 0

  readonly property bool opened: panelLoader.item
    ? panelLoader.item.opened === true
    : false

  function open() {
    if (panelLoader.item) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item) panelLoader.item.close()
  }

  function toggle() {
    if (panelLoader.item) panelLoader.item.toggle()
  }

  function injectPanel() {
    if (!panelLoader.item) return
    panelLoader.item.bar = root.bar
    panelLoader.item.anchorItem = root
    panelLoader.item.hostWidget = root
  }

  onBarChanged: injectPanel()

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
          // Update panel if it's open
          if (panelLoader.item) {
            panelLoader.item.cpuPercent = value
          }
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

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: root.toggle()
    
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
