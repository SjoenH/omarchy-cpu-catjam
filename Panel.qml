import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "henry.cpu-catjam"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property real cpuPercent: 0

  function open() {
    root.controller.show()
  }

  function close() {
    root.controller.hide()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.hostWidget || root, direction)
    return false
  }

  // CPU usage monitor
  Process {
    id: cpuMonitor
    command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'"]
    running: root.opened
    
    onExited: function(exitCode, exitStatus) {
      if (exitCode === 0 && stdout) {
        var output = stdout.trim()
        var value = parseFloat(output)
        if (!isNaN(value)) {
          cpuPercent = value
        }
      }
      if (root.opened) {
        restartTimer.start()
      }
    }
  }

  Timer {
    id: restartTimer
    interval: 200  // Update faster when panel is open
    repeat: false
    onTriggered: if (root.opened) cpuMonitor.running = true
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(280))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: content
        width: parent.width
        spacing: Style.space(12)
        padding: Style.space(4)

        Text {
          width: parent.width
          text: "CPU Catjam"
          color: root.barForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.subtitle
          font.bold: true
        }

        // CPU percentage display
        Row {
          width: parent.width
          spacing: Style.space(8)

          Text {
            text: "CPU Usage:"
            color: root.barForeground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
          }

          Text {
            text: cpuPercent.toFixed(1) + "%"
            color: root.barForeground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
          }
        }

        // Visual CPU bar
        Rectangle {
          width: parent.width - Style.space(8)
          height: Style.space(20)
          color: Qt.rgba(root.barForeground.r, root.barForeground.g, root.barForeground.b, 0.1)
          radius: Style.space(4)

          Rectangle {
            width: parent.width * (cpuPercent / 100)
            height: parent.height
            color: {
              if (cpuPercent < 30) return "#00cc66"
              if (cpuPercent < 70) return "#ffaa00"
              return "#ff4444"
            }
            radius: Style.space(4)

            Behavior on width {
              NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }
          }
        }

        // Animation speed indicator
        Column {
          width: parent.width
          spacing: Style.space(4)

          Text {
            text: "Animation Speed:"
            color: root.barForeground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
          }

          Text {
            text: {
              var speed = 0.5 + (cpuPercent / 100) * 2.5
              return speed.toFixed(2) + "x"
            }
            color: root.barForeground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
            opacity: 0.7
          }
        }

        // Info text
        Text {
          width: parent.width - Style.space(8)
          text: "The catjam speed adjusts from 0.5x (idle) to 3x (100% CPU)"
          color: root.barForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          opacity: 0.6
          wrapMode: Text.WordWrap
        }
      }
    }
  }
}
