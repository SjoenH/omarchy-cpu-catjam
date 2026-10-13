import QtQuick
import qs.Commons
import qs.Ui

Panel {
    id: root

    property var anchorItem: null
    property var hostWidget: null
    property real cpuPercent: 0
    readonly property color foreground: root.barForeground
    readonly property string fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
    readonly property string currentGif: root.hostWidget ? root.hostWidget.currentGif : "catjam.gif"
    // 0.5x at 0% CPU, up to 3x at 100% CPU: the same curve as the bar.
    readonly property real speed: 0.5 + (root.cpuPercent / 100) * 2.5

    function open() {
        root.controller.show();
    }

    function close() {
        root.controller.hide();
    }

    function switchPanel(direction) {
        if (root.bar && typeof root.bar.switchPanelFrom === "function")
            return root.bar.switchPanelFrom(root.hostWidget || root, direction);

        return false;
    }

    function mood() {
        if (root.cpuPercent < 20)
            return "Chill vibes";

        if (root.cpuPercent < 60)
            return "Getting into it";

        return "Maximum overdrive";
    }

    // CONVENTION-EXCEPTION: load is green, amber or red on every theme.
    function loadColor() {
        if (root.cpuPercent < 30)
            return "#00cc66";

        if (root.cpuPercent < 70)
            return "#ffaa00";

        return "#ff4444";
    }

    objectName: "cpuCatjamPanel"
    moduleName: "no.koka.cpu-catjam"
    manageIpc: false
    Accessible.role: Accessible.Dialog
    Accessible.name: "CPU Catjam"

    KeyboardPanel {
        id: panel

        anchorItem: root.anchorItem
        owner: root.hostWidget || root
        bar: root.bar
        open: root.opened
        focusTarget: keyCatcher
        contentWidth: panel.fittedContentWidth(Style.space(340))
        contentHeight: panel.fittedContentHeight(content.implicitHeight)

        PanelKeyCatcher {
            id: keyCatcher

            anchors.fill: parent
            onCloseRequested: root.close()
            onTabRequested: function(direction) {
                root.switchPanel(direction);
            }

            Column {
                id: content

                width: parent.width
                spacing: Style.space(12)

                PanelTitle {
                    width: parent.width
                    caption: "Your CPU is at " + Math.round(root.cpuPercent) + "%"
                    leftWord: "CPU"
                    rightWord: "Catjam"
                    foreground: root.foreground
                    fontFamily: root.fontFamily

                    // The chosen animation, jamming at the bar's speed.
                    AnimatedImage {
                        anchors.fill: parent
                        source: Qt.resolvedUrl(root.currentGif)
                        fillMode: Image.PreserveAspectFit
                        playing: root.opened
                        speed: root.speed
                    }

                }

                StatCard {
                    objectName: "usageCard"
                    width: parent.width
                    name: "CPU usage"
                    detail: root.mood()
                    value: root.cpuPercent.toFixed(1)
                    unit: "%"
                    note: root.speed.toFixed(2) + "× speed"
                    progress: root.cpuPercent / 100
                    markerColor: root.loadColor()
                    foreground: root.foreground
                    fontFamily: root.fontFamily
                }

                AnimationPicker {
                    objectName: "animationPicker"
                    width: parent.width
                    options: root.hostWidget ? root.hostWidget.gifOptions : []
                    value: root.currentGif
                    speed: root.speed
                    playing: root.opened
                    foreground: root.foreground
                    fontFamily: root.fontFamily
                    onChanged: function(v) {
                        if (root.hostWidget)
                            root.hostWidget.changeGif(v);

                    }
                }

            }

        }

    }

}
