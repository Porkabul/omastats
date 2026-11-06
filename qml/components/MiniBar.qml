import QtQuick

// A small filled bar. Horizontal fills left to right; vertical fills bottom to
// top. `fraction` is 0..1.
Item {
    id: root

    property real fraction: 0
    property bool vertical: false
    property real length: 16
    property real thickness: 4
    property color fillColor: "white"
    property color trackColor: "transparent"
    property int rounding: 2

    readonly property real f: Math.max(0, Math.min(1, Number(fraction) || 0))

    implicitWidth: vertical ? thickness : length
    implicitHeight: vertical ? length : thickness
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: root.rounding
        color: root.trackColor
    }

    Rectangle {
        id: fill
        x: 0
        y: root.vertical ? parent.height - height : 0
        width: root.vertical ? parent.width : Math.round(parent.width * root.f)
        height: root.vertical ? Math.round(parent.height * root.f) : parent.height
        radius: root.rounding
        color: root.fillColor

        Behavior on width {
            enabled: !root.vertical
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }
        Behavior on height {
            enabled: root.vertical
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }
    }
}
