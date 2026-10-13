import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    property real cpuPercent: 0
    readonly property var gifOptions: [{
        "value": "catjam.gif",
        "label": "Catjam"
    }, {
        "value": "parrot.gif",
        "label": "Parrot"
    }, {
        "value": "cool-doge.gif",
        "label": "Cool Doge"
    }, {
        "value": "confused_dog.gif",
        "label": "Confused Dog"
    }, {
        "value": "nyancat.gif",
        "label": "Nyan Cat"
    }]
    readonly property string defaultGif: "catjam.gif"
    // The gif setting comes from shell.json. Only a bundled animation is ever
    // loaded: an unknown name would leave the widget blank, and a path or URL
    // would make it read or fetch whatever the setting points at.
    property string currentGif: root.knownGif(setting("gif", root.defaultGif))
    readonly property int imageSize: Math.min(24, root.barSize - 2)
    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

    function open() {
        if (panelLoader.item)
            panelLoader.item.open();

    }

    function close() {
        if (panelLoader.item)
            panelLoader.item.close();

    }

    function toggle() {
        if (panelLoader.item)
            panelLoader.item.toggle();

    }

    function injectPanel() {
        if (!panelLoader.item)
            return ;

        panelLoader.item.bar = root.bar;
        panelLoader.item.anchorItem = root;
        panelLoader.item.hostWidget = root;
    }

    function knownGif(file) {
        for (var i = 0; i < root.gifOptions.length; i++) {
            if (root.gifOptions[i].value === file)
                return file;

        }
        return root.defaultGif;
    }

    function changeGif(gifFile) {
        var entry = {
            "id": root.moduleName
        };
        for (var key in root.settings) if (key !== "id") {
            entry[key] = root.settings[key];
        }
        entry["gif"] = root.knownGif(gifFile);
        root.settings = entry;
        if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
            root.bar.shell.updateEntryInline(root.moduleName, entry);

    }

    moduleName: "no.koka.cpu-catjam"
    implicitWidth: catjamImage.width + 8
    // Exactly the bar's height. Being taller than the bar made the whole
    // section taller, which shifted every widget next to this one.
    implicitHeight: root.barSize
    onBarChanged: injectPanel()

    // CPU usage monitor using vmstat
    Process {
        id: cpuMonitor

        command: ["sh", "-c", "vmstat 1 2 | tail -1 | awk '{print 100-$15}'"]
        running: true
        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0 && stdoutCollector.data) {
                var output = String(stdoutCollector.data).trim();
                var value = parseFloat(output);
                if (!isNaN(value)) {
                    cpuPercent = value;
                    // Update panel if it's open
                    if (panelLoader.item)
                        panelLoader.item.cpuPercent = value;

                }
            }
            // Restart after 1500ms (vmstat takes 1 second)
            restartTimer.start();
        }

        stdout: StdioCollector {
            id: stdoutCollector
        }

    }

    Timer {
        id: restartTimer

        interval: 1500
        repeat: false
        onTriggered: cpuMonitor.running = true
    }

    Loader {
        id: panelLoader

        active: true
        source: Qt.resolvedUrl("Panel.qml")
        visible: false
        onLoaded: {
            root.injectPanel();
            Qt.callLater(root.injectPanel);
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            if (root.bar)
                root.bar.showTooltip(root, "CPU: " + cpuPercent.toFixed(1) + "%");

        }
        onExited: {
            if (root.bar)
                root.bar.hideTooltip(root);

        }
        onClicked: root.toggle()

        AnimatedImage {
            id: catjamImage

            objectName: "animation"
            anchors.centerIn: parent
            source: Qt.resolvedUrl(root.currentGif)
            width: root.imageSize
            height: root.imageSize
            fillMode: Image.PreserveAspectFit
            playing: true
            speed: {
                // Adjust playback speed based on CPU
                // 0.5x at 0% CPU, up to 3x at 100% CPU
                return 0.5 + (cpuPercent / 100) * 2.5;
            }
        }

    }

}
