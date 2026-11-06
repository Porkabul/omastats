import QtQuick

// One metric on the bar: an optional mini bar, its short name, and its value.
// `compact` is the vertical-bar shape: a smaller bar and a one-letter name,
// because a side bar is only one icon wide.
Item {
    id: root

    property string label: ""
    property string shortLabel: ""
    property string valueText: ""
    property real fraction: 0
    property color fillColor: "white"
    property color valueColor: "white"
    property bool showBar: true
    property bool showLabel: true
    property bool showValue: true
    property bool compact: false
    property bool verticalBar: false
    property real barLength: 16
    property real barThickness: 4
    property int rounding: 2
    property color trackColor: "transparent"
    property color textColor: "white"
    property string fontFamily: ""
    property real fontSize: 12
    property string separator: ""
    property bool showSeparator: false

    // Leading and trailing spaces in a label become real margins, so " CPU "
    // reads with air on both sides rather than depending on how the font
    // happens to shape whitespace.
    TextMetrics {
        id: labelSpace
        font.family: root.fontFamily
        font.pixelSize: root.fontSize
        text: " "
    }

    readonly property var labelParts: {
        const raw = String(root.label === undefined || root.label === null ? "" : root.label)
        let lead = 0
        while (lead < raw.length && raw.charCodeAt(lead) === 32) lead++
        let trail = 0
        while (trail < raw.length - lead && raw.charCodeAt(raw.length - 1 - trail) === 32) trail++
        return { leading: lead, trailing: trail, core: raw.slice(lead, raw.length - trail) }
    }
    readonly property real spaceWidth: labelSpace.advanceWidth
    readonly property string labelCore: root.compact
        ? (root.shortLabel !== "" ? root.shortLabel : root.label)
        : root.labelParts.core
    readonly property real labelPadLeft: root.compact ? 0 : root.labelParts.leading * root.spaceWidth
    readonly property real labelPadRight: root.compact ? 0 : root.labelParts.trailing * root.spaceWidth

    implicitWidth: row.implicitWidth
    implicitHeight: Math.max(row.implicitHeight, verticalBar ? barLength : barThickness)

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.compact ? 2 : 3

        MiniBar {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showBar
            vertical: root.verticalBar
            length: root.barLength
            thickness: root.barThickness
            fraction: root.fraction
            fillColor: root.fillColor
            trackColor: root.trackColor
            rounding: root.rounding
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showLabel
            implicitWidth: labelText.implicitWidth + root.labelPadLeft + root.labelPadRight
            implicitHeight: labelText.implicitHeight

            Text {
                id: labelText
                x: root.labelPadLeft
                textFormat: Text.PlainText
                text: root.labelCore
                color: root.textColor
                opacity: 0.72
                font.family: root.fontFamily
                font.pixelSize: root.fontSize
                renderType: Text.NativeRendering
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showValue && !root.compact
            textFormat: Text.PlainText
            text: root.valueText
            color: root.valueColor
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            renderType: Text.NativeRendering
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showSeparator && !root.compact
            textFormat: Text.PlainText
            text: root.separator
            color: root.textColor
            opacity: 0.35
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            renderType: Text.NativeRendering
        }
    }
}
