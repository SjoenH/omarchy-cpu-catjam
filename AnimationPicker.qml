import QtQuick
import qs.Commons
import qs.Ui

// The bundled animations as a row of playing tiles; the chosen one is
// outlined in the accent colour. `options` is [{ value, label }], where
// value is the gif's file name.
Column {
    id: root

    property var options: []
    property string value: ""
    property real speed: 1
    property bool playing: true
    property color foreground: Color.foreground
    property color accent: Color.accent
    property string fontFamily: Style.font.family
    property string hoveredLabel: ""
    readonly property int gap: Style.spacing.lg
    readonly property real tileSize: options.length > 0 ? Math.floor((width - gap * (options.length - 1)) / options.length) : 0

    signal changed(string value)

    function labelOf(file) {
        for (var i = 0; i < options.length; i++) {
            if (options[i].value === file)
                return options[i].label;

        }
        return "";
    }

    function tint(amount) {
        var from = Color.popups.background;
        return Qt.rgba(from.r + (foreground.r - from.r) * amount, from.g + (foreground.g - from.g) * amount, from.b + (foreground.b - from.b) * amount, 1);
    }

    spacing: Style.spacing.md

    Row {
        spacing: root.gap

        Repeater {
            model: root.options

            BorderSurface {
                id: tile

                required property var modelData
                readonly property bool selected: modelData.value === root.value
                readonly property bool hot: tileMouse.containsMouse || activeFocus

                objectName: "animationTile-" + modelData.value
                width: root.tileSize
                height: root.tileSize
                radius: Style.cornerRadius
                color: root.tint(selected ? 0.14 : (hot ? 0.1 : 0.05))
                borderSpec: selected ? Border.flat(root.accent, Math.max(1, Style.space(2))) : Border.none()
                activeFocusOnTab: true
                Accessible.role: Accessible.RadioButton
                Accessible.name: modelData.label
                Accessible.checked: selected
                Keys.onReturnPressed: root.changed(modelData.value)
                Keys.onEnterPressed: root.changed(modelData.value)
                Keys.onSpacePressed: root.changed(modelData.value)

                AnimatedImage {
                    anchors.centerIn: parent
                    width: Math.round(parent.width * 0.62)
                    height: width
                    source: Qt.resolvedUrl(tile.modelData.value)
                    fillMode: Image.PreserveAspectFit
                    playing: root.playing
                    speed: root.speed
                }

                MouseArea {
                    id: tileMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onContainsMouseChanged: root.hoveredLabel = containsMouse ? tile.modelData.label : ""
                    onClicked: root.changed(tile.modelData.value)
                }

            }

        }

    }

    Text {
        objectName: "animationName"
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.PlainText
        text: root.hoveredLabel !== "" ? root.hoveredLabel : root.labelOf(root.value)
        color: Qt.darker(root.foreground, 1.55)
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
    }

}
