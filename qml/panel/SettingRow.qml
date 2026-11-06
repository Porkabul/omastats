import QtQuick
import QtQuick.Layouts
import "../controls"

// One setting row: name + hint on the left, current value / reset on the
// right, and a control underneath. Every change is applied instantly and
// saved by the store the panel owns.
Item {
    id: root

    property var ui: null
    property string settingKey: ""
    property string label: ""
    property string hint: ""
    property string kind: "string"
    property var options: []
    property var labels: ({})
    property var presets: []
    property var value: null
    property var defaultValue: null
    property real min: 0
    property real max: 100
    property real step: 1
    property string unit: ""
    property int maxLength: 256
    property bool dimmed: false

    signal edited(var v)

    // Show a choice immediately, don't wait for the round trip through the
    // store and back through the widget's resolved config.
    property var optimistic: undefined
    readonly property var current: optimistic !== undefined ? optimistic : value
    onValueChanged: optimistic = undefined
    function commit(v) { optimistic = v; edited(v) }

    function str(v) { return (v === null || v === undefined) ? "" : String(v) }
    function same(a, b) { return str(a).toLowerCase() === str(b).toLowerCase() }
    function labelFor(opt) {
        return labels[opt] !== undefined ? labels[opt] : String(opt)
    }
    function show(v) {
        const n = Number(v)
        if (!isFinite(n)) return "?"
        return String(parseFloat(n.toFixed(2)))
    }
    function unitSuffix() {
        if (root.unit === "") return ""
        return (root.unit === "%" || root.unit === "°") ? root.unit : " " + root.unit
    }
    function fmtValue(v) { return show(v) + unitSuffix() }
    function nudge(dir) {
        const cur = Number(current)
        const v = Math.max(min, Math.min(max, cur + dir * step))
        if (v !== cur) commit(v)
    }
    function validHex(s) { return /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.test(str(s)) }

    readonly property bool boolValue: current === true || current === "true"
    readonly property bool atDefault: same(current, defaultValue)
    readonly property real span: Math.max(1e-9, max - min)
    readonly property real frac: Math.max(0, Math.min(1, (Number(current) - min) / span))
    readonly property real defFrac: Math.max(0, Math.min(1, (Number(defaultValue) - min) / span))
    readonly property bool useSegments: kind === "enum" && options.length <= 4

    implicitWidth: 400
    implicitHeight: col.implicitHeight
    opacity: dimmed ? 0.4 : 1.0
    Behavior on opacity { enabled: ui && ui.animations; NumberAnimation { duration: 140 } }

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: ui ? ui.px(9) : 9

        RowLayout {
            Layout.fillWidth: true
            spacing: ui ? ui.px(10) : 10

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Txt {
                    ui: root.ui
                    Layout.fillWidth: true
                    text: root.label
                    font.pixelSize: ui.fs(13)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Txt {
                    ui: root.ui
                    Layout.fillWidth: true
                    visible: root.hint !== ""
                    text: root.hint
                    font.pixelSize: ui.fs(10)
                    opacity: 0.55
                    wrapMode: Text.Wrap
                }
            }

            // - value +
            RowLayout {
                visible: root.kind === "int"
                spacing: ui.px(6)
                Layout.alignment: Qt.AlignTop
                Btn { ui: root.ui; text: "\u2212"; implicitWidth: ui.px(28); implicitHeight: ui.px(28); onClicked: root.nudge(-1) }
                Txt {
                    ui: root.ui
                    Layout.minimumWidth: ui.px(54)
                    horizontalAlignment: Text.AlignHCenter
                    text: root.fmtValue(root.current)
                    font.pixelSize: ui.fs(12)
                    font.weight: Font.DemiBold
                }
                Btn { ui: root.ui; text: "+"; implicitWidth: ui.px(28); implicitHeight: ui.px(28); onClicked: root.nudge(1) }
            }

            // reset arrow, only when changed
            Rectangle {
                visible: !root.atDefault
                Layout.alignment: Qt.AlignTop
                implicitWidth: ui.px(24); implicitHeight: ui.px(24)
                radius: ui.r(0.5)
                color: ui.tint(resetArea.containsMouse ? 0.18 : 0.08)
                Txt { ui: root.ui; anchors.centerIn: parent; text: "\u21BA"; font.pixelSize: ui.fs(12) }
                MouseArea {
                    id: resetArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.commit(root.defaultValue)
                }
            }

            Sw {
                Layout.alignment: Qt.AlignVCenter
                visible: root.kind === "bool"
                k: 1
                animate: ui.animations
                ink: ui.fg; accent: ui.accent; knob: ui.accentText
                on: root.boolValue
                onFlipped: root.commit(!root.boolValue)
            }
        }

        // segmented control
        Rectangle {
            Layout.fillWidth: true
            visible: root.useSegments
            implicitHeight: ui.px(38)
            radius: ui.r(1.4)
            color: ui.tint(0.05)
            border.width: 1
            border.color: ui.tint(0.08)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 3
                spacing: 2

                Repeater {
                    model: root.useSegments ? root.options : []
                    delegate: Rectangle {
                        readonly property bool on: root.same(root.current, modelData)
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true
                        radius: ui.r(1.1)
                        color: on ? ui.accent : (sArea.containsMouse ? ui.tint(0.08) : "transparent")
                        Behavior on color { enabled: ui.animations; ColorAnimation { duration: 90 } }
                        Txt {
                            ui: root.ui
                            anchors.centerIn: parent
                            width: parent.width - ui.px(8)
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            text: root.labelFor(modelData)
                            color: parent.on ? ui.accentText : ui.fg
                            font.pixelSize: ui.fs(11)
                            font.weight: parent.on ? Font.DemiBold : Font.Normal
                        }
                        MouseArea {
                            id: sArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.commit(modelData)
                        }
                    }
                }
            }
        }

        // chips
        Flow {
            Layout.fillWidth: true
            visible: root.kind === "enum" && !root.useSegments
            spacing: ui.px(6)
            Repeater {
                model: (root.kind === "enum" && !root.useSegments) ? root.options : []
                delegate: Chip {
                    ui: root.ui
                    label: root.labelFor(modelData)
                    on: root.same(root.current, modelData)
                    onClicked: root.commit(modelData)
                }
            }
        }

        // slider
        ColumnLayout {
            Layout.fillWidth: true
            visible: root.kind === "int"
            spacing: ui.px(2)

            Item {
                id: track
                Layout.fillWidth: true
                implicitHeight: ui.px(24)

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width; height: 6; radius: 3
                    color: ui.tint(0.12)
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * root.frac; height: 6; radius: 3
                    color: ui.accent
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: parent.width * root.defFrac - 1
                    width: 2; height: 12
                    color: ui.tint(0.45)
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: Math.max(0, Math.min(parent.width - width, parent.width * root.frac - width / 2))
                    width: ui.px(16); height: width; radius: width / 2
                    color: ui.accent
                    border.width: 2
                    border.color: ui.surface
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    function apply(mx) {
                        const f = Math.max(0, Math.min(1, mx / width))
                        const raw = root.min + f * root.span
                        let snapped = root.min + Math.round((raw - root.min) / root.step) * root.step
                        snapped = Math.max(root.min, Math.min(root.max, snapped))
                        if (snapped !== Number(root.current)) root.commit(snapped)
                    }
                    onPressed: function(m) { apply(m.x) }
                    onPositionChanged: function(m) { if (pressed) apply(m.x) }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Txt { ui: root.ui; text: root.fmtValue(root.min); font.pixelSize: ui.fs(9); opacity: 0.5 }
                Item { Layout.fillWidth: true }
                Txt { ui: root.ui; text: root.fmtValue(root.max); font.pixelSize: ui.fs(9); opacity: 0.5 }
            }
        }

        // text field
        Rectangle {
            Layout.fillWidth: true
            visible: root.kind === "string" || root.kind === "color"
            implicitHeight: ui.px(34)
            radius: ui.r(1.4)
            color: ui.tint(0.05)
            border.width: 1
            border.color: field.activeFocus ? ui.tint(0.28) : ui.tint(0.08)
            clip: true

            TextBox {
                id: field
                ui: root.ui
                anchors.fill: parent
                anchors.leftMargin: ui.px(12)
                anchors.rightMargin: ui.px(12)
                text: root.str(root.current)
                maximumLength: root.maxLength
                onEditingFinished: {
                    if (root.kind === "color" && !root.validHex(text)) { text = root.str(root.current); return }
                    if (text !== root.str(root.current)) root.commit(text)
                }
                Keys.onEscapePressed: { text = root.str(root.current); focus = false }
                Connections {
                    target: root
                    function onCurrentChanged() { field.text = root.str(root.current) }
                }
            }
        }

        // presets
        Flow {
            Layout.fillWidth: true
            visible: root.kind === "string" && root.presets.length > 0
            spacing: ui.px(6)
            Repeater {
                model: (root.kind === "string") ? root.presets : []
                delegate: Chip {
                    ui: root.ui
                    label: String(modelData).trim() === "" ? "(none)" : String(modelData)
                    on: root.same(root.current, modelData)
                    onClicked: root.commit(modelData)
                }
            }
        }

        // swatches
        Flow {
            Layout.fillWidth: true
            visible: root.kind === "color"
            spacing: ui.px(10)
            Repeater {
                model: (root.kind === "color") ? root.presets : []
                delegate: Rectangle {
                    readonly property bool on: root.same(root.current, modelData)
                    width: ui.px(28); height: width; radius: width / 2
                    color: modelData
                    border.width: on ? 2 : 1
                    border.color: on ? ui.fg : ui.tint(0.25)
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.commit(modelData)
                    }
                }
            }
        }
    }
}
