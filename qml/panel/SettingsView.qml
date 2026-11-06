import QtQuick
import QtQuick.Layouts
import qs.Commons
import "../js/Schema.js" as Schema
import "../js/Format.js" as Format
import "../core"
import "../components"
import "../controls"

// The OmaStats settings panel, used both docked under the bar and in its own
// floating window. Tabs follow Schema.groups; a search covers every group; the
// preview at the top is drawn from the same values as the bar itself.
Item {
    id: root

    property var store: null
    property var cfg: ({})
    property var strings: null
    property bool popped: false

    signal closeRequested()
    signal popOutRequested()
    signal dockRequested()

    property int group: 0
    property string query: ""
    property bool confirmReset: false

    readonly property var values: cfg && typeof cfg === "object" ? cfg : Schema.defaults()
    readonly property string activeGroup: group
    readonly property bool searching: query.trim() !== ""
    readonly property int groupCount: Schema.groups.length
    readonly property bool onAbout: group >= groupCount && !searching

    Theme {
        id: theme
        surfaceOpacity: Number(root.values.panelOpacity || 100) / 100
    }

    function t(key, fallback) {
        return root.strings ? root.strings.t(key, fallback) : fallback
    }
    function val(key) {
        return root.values[key] !== undefined ? root.values[key] : Schema.defaults()[key]
    }
    function same(a, b) { return String(a).toLowerCase() === String(b).toLowerCase() }
    function isChanged(item) { return !same(val(item.key), item.fallback) }
    function dimmed(item) { return !Schema.active(item, root.values) }
    function setValue(key, v) { if (root.store) root.store.set(key, v) }

    function itemLabel(item) { return t("item." + item.key + ".label", item.label) }
    function itemHint(item) { return t("item." + item.key + ".hint", item.hint) }
    function optionLabels(item) {
        const out = {}
        const opts = item.options || []
        for (let i = 0; i < opts.length; i++) {
            out[opts[i]] = t("opt." + item.key + "." + opts[i],
                item.optionLabels && item.optionLabels[opts[i]] !== undefined
                    ? item.optionLabels[opts[i]] : String(opts[i]))
        }
        return out
    }

    function matches(item, q) {
        if (q === "") return true
        const hay = (item.key + " " + itemLabel(item) + " " + itemHint(item)).toLowerCase()
        return q.split(/\s+/).every(function(w) { return hay.indexOf(w) >= 0 })
    }

    // Rows for the selected tab, or every match while searching. A row carries
    // the group heading to draw above it when searching.
    readonly property var rows: {
        const out = []
        const q = root.query.trim().toLowerCase()
        for (let g = 0; g < Schema.groups.length; g++) {
            if (q === "" && g !== root.group) continue
            const grp = Schema.groups[g]
            let first = true
            for (let i = 0; i < grp.items.length; i++) {
                const it = grp.items[i]
                if (!root.matches(it, q)) continue
                out.push({
                    item: it,
                    head: q !== "" && first ? root.t("tab." + grp.key, grp.title) : ""
                })
                first = false
            }
        }
        return out
    }

    readonly property int changedCount: {
        let n = 0
        for (let g = 0; g < Schema.groups.length; g++) {
            const items = Schema.groups[g].items
            for (let i = 0; i < items.length; i++) if (root.isChanged(items[i])) n++
        }
        return n
    }

    function resetAll() {
        if (!root.store) return
        if (!root.confirmReset) {
            root.confirmReset = true
            confirmTimer.restart()
            return
        }
        root.confirmReset = false
        root.store.resetAll(Schema.defaults())
    }
    Timer { id: confirmTimer; interval: 2600; onTriggered: root.confirmReset = false }

    focus: true
    Keys.onEscapePressed: function(e) {
        root.closeRequested()
        e.accepted = true
    }

    Rectangle {
        visible: root.popped
        anchors.fill: parent
        radius: theme.r(3)
        color: theme.panelColor
        border.width: 1
        border.color: theme.tint(0.16)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.popped ? theme.px(16) : 0
        spacing: theme.px(10)

        // ---- header ---------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: theme.px(10)

            Rectangle {
                width: theme.px(30); height: width
                radius: theme.r(1.5)
                color: theme.accentTint(0.16)
                border.width: 1
                border.color: theme.accentTint(0.35)
                Txt {
                    ui: theme
                    anchors.centerIn: parent
                    text: "\u25a4"
                    color: theme.accent
                    font.pixelSize: theme.fs(15)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Txt {
                    ui: theme
                    text: "OmaStats"
                    font.pixelSize: theme.fs(15)
                    font.weight: Font.DemiBold
                }
                Txt {
                    ui: theme
                    Layout.fillWidth: true
                    text: root.t("panel.subtitle", "CPU · GPU · memory · disks · network")
                    font.pixelSize: theme.fs(10)
                    opacity: 0.5
                    elide: Text.ElideRight
                }
            }

            Btn {
                ui: theme
                text: "\u2715"
                implicitWidth: theme.px(30)
                implicitHeight: theme.px(30)
                onClicked: root.closeRequested()
            }
        }

        // ---- live preview ---------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: previewRow.implicitHeight + theme.px(18)
            radius: theme.r(1.5)
            color: theme.tint(0.04)
            border.width: 1
            border.color: theme.tint(0.08)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: theme.px(12)
                anchors.rightMargin: theme.px(12)
                spacing: theme.px(10)

                Txt {
                    ui: theme
                    text: root.t("panel.preview", "PREVIEW")
                    font.pixelSize: theme.fs(8)
                    font.letterSpacing: 1
                    font.weight: Font.DemiBold
                    opacity: 0.4
                }

                Item { Layout.fillWidth: true }

                Row {
                    id: previewRow
                    spacing: root.values.gap

                    MetricChip {
                        label: root.values.labelCpu; shortLabel: "C"
                        valueText: Format.pct(62, root.values.showUnits)
                        fraction: Format.fraction(62, root.values.cpuMin, root.values.cpuMax)
                        fillColor: Format.colorFor(62, root.values.cpuWarn, root.values.cpuCrit, root.values)
                        valueColor: root.values.colorText ? fillColor : theme.fg
                        showBar: root.values.display !== "text"
                        showLabel: root.values.labels
                        showValue: root.values.display !== "bar"
                        verticalBar: root.values.barOrientation === "vertical"
                        barLength: root.values.barLength
                        barThickness: root.values.barThickness
                        rounding: root.values.barRounding
                        trackColor: Qt.rgba(fillColor.r, fillColor.g, fillColor.b, root.values.barTrackOpacity / 100)
                        textColor: theme.fg
                        fontFamily: theme.fontName
                        fontSize: theme.fs(12)
                        separator: root.values.separator
                        showSeparator: root.values.labels
                    }

                    MetricChip {
                        label: root.values.labelRam; shortLabel: "M"
                        valueText: Format.pct(78, root.values.showUnits)
                        fraction: Format.fraction(78, root.values.ramMin, root.values.ramMax)
                        fillColor: Format.colorFor(78, root.values.ramWarn, root.values.ramCrit, root.values)
                        valueColor: root.values.colorText ? fillColor : theme.fg
                        showBar: root.values.display !== "text"
                        showLabel: root.values.labels
                        showValue: root.values.display !== "bar"
                        verticalBar: root.values.barOrientation === "vertical"
                        barLength: root.values.barLength
                        barThickness: root.values.barThickness
                        rounding: root.values.barRounding
                        trackColor: Qt.rgba(fillColor.r, fillColor.g, fillColor.b, root.values.barTrackOpacity / 100)
                        textColor: theme.fg
                        fontFamily: theme.fontName
                        fontSize: theme.fs(12)
                        separator: root.values.separator
                        showSeparator: root.values.labels
                    }

                    MetricChip {
                        label: root.values.labelDisk !== "" ? root.values.labelDisk : "DSK"; shortLabel: "D"
                        valueText: Format.pct(42, root.values.showUnits)
                        fraction: Format.fraction(42, root.values.diskMin, root.values.diskMax)
                        fillColor: Format.colorFor(42, root.values.diskWarn, root.values.diskCrit, root.values)
                        valueColor: root.values.colorText ? fillColor : theme.fg
                        showBar: root.values.display !== "text"
                        showLabel: root.values.labels
                        showValue: root.values.display !== "bar"
                        verticalBar: root.values.barOrientation === "vertical"
                        barLength: root.values.barLength
                        barThickness: root.values.barThickness
                        rounding: root.values.barRounding
                        trackColor: Qt.rgba(fillColor.r, fillColor.g, fillColor.b, root.values.barTrackOpacity / 100)
                        textColor: theme.fg
                        fontFamily: theme.fontName
                        fontSize: theme.fs(12)
                    }
                }
            }
        }

        // ---- search ---------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: theme.px(30)
            radius: theme.r(1.5)
            color: theme.tint(0.05)
            border.width: 1
            border.color: searchBox.activeFocus ? theme.accentTint(0.5) : theme.tint(0.08)
            clip: true

            Txt {
                ui: theme
                anchors.left: parent.left; anchors.leftMargin: theme.px(10)
                anchors.verticalCenter: parent.verticalCenter
                text: "\u2315"
                opacity: 0.5
                font.pixelSize: theme.fs(14)
            }
            TextBox {
                id: searchBox
                ui: theme
                anchors.fill: parent
                anchors.leftMargin: theme.px(30)
                anchors.rightMargin: theme.px(30)
                maximumLength: 60
                text: root.query
                onTextChanged: root.query = text
                Txt {
                    ui: theme
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    elide: Text.ElideRight
                    visible: searchBox.text === "" && !searchBox.activeFocus
                    text: root.t("panel.search", "Search settings…")
                    opacity: 0.4
                }
            }
            Txt {
                ui: theme
                anchors.right: parent.right; anchors.rightMargin: theme.px(10)
                anchors.verticalCenter: parent.verticalCenter
                visible: searchBox.text !== ""
                text: "\u2715"
                opacity: 0.6
                MouseArea {
                    anchors.fill: parent; anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { searchBox.text = ""; root.query = "" }
                }
            }
        }

        // ---- tabs -----------------------------------------------------------
        Item {
            Layout.fillWidth: true
            implicitHeight: theme.px(32)

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: theme.tint(0.10)
            }

            Flickable {
                id: tabsFlick
                anchors.fill: parent
                contentWidth: tabsRow.implicitWidth
                contentHeight: height
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Row {
                    id: tabsRow
                    height: tabsFlick.height
                    spacing: 0

                    Repeater {
                        model: Schema.groups.concat([Schema.about])
                        delegate: Item {
                            readonly property bool on: index === root.group && !root.searching
                            width: tabLabel.implicitWidth + theme.px(24)
                            height: tabsFlick.height

                            Txt {
                                id: tabLabel
                                ui: theme
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -1
                                text: root.t("tab." + modelData.key, modelData.title)
                                opacity: root.searching ? 0.3 : (parent.on ? 1.0 : (tabArea.containsMouse ? 0.8 : 0.5))
                                font.pixelSize: theme.fs(12)
                                font.weight: parent.on ? Font.DemiBold : Font.Normal
                            }
                            Rectangle {
                                visible: parent.on
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 2
                                radius: 1
                                color: theme.accent
                            }
                            MouseArea {
                                id: tabArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.group = index
                                    root.query = ""
                                    searchBox.text = ""
                                    flick.contentY = 0
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---- about ----------------------------------------------------------
        Flickable {
            visible: root.onAbout
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: aboutCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: aboutCol
                width: parent.width
                spacing: theme.px(10)

                Txt {
                    ui: theme
                    Layout.fillWidth: true
                    text: "OmaStats"
                    font.pixelSize: theme.fs(20)
                    font.weight: Font.DemiBold
                }
                Txt {
                    ui: theme
                    Layout.fillWidth: true
                    text: root.t("about.version", "Version 1.0.0 · MIT · by porkabul")
                    font.pixelSize: theme.fs(10)
                    opacity: 0.5
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: theme.tint(0.10) }
                Txt {
                    ui: theme
                    Layout.fillWidth: true
                    text: root.t("about.description", "CPU, GPU, memory, disks and network in the Omarchy bar, with three-colour thresholds and a bar or text for every reading.")
                    font.pixelSize: theme.fs(12)
                    wrapMode: Text.Wrap
                    lineHeight: 1.25
                }
                Txt {
                    ui: theme
                    Layout.fillWidth: true
                    text: root.t("about.thresholds", "Each metric has its own minimum, maximum, middle threshold and high threshold. Below the middle threshold the low colour is used, between the two the middle colour, and at or above the high threshold the high colour.")
                    font.pixelSize: theme.fs(11)
                    opacity: 0.7
                    wrapMode: Text.Wrap
                    lineHeight: 1.25
                }
                Txt {
                    ui: theme
                    Layout.fillWidth: true
                    text: root.t("about.data", "Readings come from /proc, /sys and df. A sensor this machine cannot read is left out instead of being drawn as zero. Network rates follow the default route unless you pin an interface.")
                    font.pixelSize: theme.fs(11)
                    opacity: 0.7
                    wrapMode: Text.Wrap
                    lineHeight: 1.25
                }
                Txt {
                    ui: theme
                    Layout.fillWidth: true
                    text: root.t("about.help", "Left or right click the bar widget to open this panel. Middle click runs btop when enabled.")
                    font.pixelSize: theme.fs(11)
                    opacity: 0.7
                    wrapMode: Text.Wrap
                    lineHeight: 1.25
                }
                Item { Layout.fillHeight: true }
            }
        }

        // ---- rows -----------------------------------------------------------
        Flickable {
            id: flick
            visible: !root.onAbout
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: rowsCol.implicitHeight + theme.px(8)
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Item {
                width: flick.width
                implicitHeight: rowsCol.implicitHeight + theme.px(8)

                ColumnLayout {
                    id: rowsCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    spacing: 0

                    Txt {
                        ui: theme
                        visible: root.rows.length === 0
                        Layout.topMargin: theme.px(18)
                        text: root.t("panel.noMatch", "No setting matches that.")
                        opacity: 0.5
                    }

                    Repeater {
                        model: root.rows
                        delegate: ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Rectangle {
                                visible: index > 0
                                Layout.fillWidth: true
                                implicitHeight: 1
                                color: theme.tint(0.07)
                            }
                            Txt {
                                ui: theme
                                visible: modelData.head !== ""
                                Layout.topMargin: theme.px(14)
                                text: modelData.head.toUpperCase()
                                font.pixelSize: theme.fs(9)
                                font.letterSpacing: 1
                                font.weight: Font.DemiBold
                                opacity: 0.45
                            }
                            SettingRow {
                                Layout.fillWidth: true
                                Layout.topMargin: theme.px(14)
                                Layout.bottomMargin: theme.px(14)
                                ui: theme
                                settingKey: modelData.item.key
                                label: root.itemLabel(modelData.item)
                                hint: root.itemHint(modelData.item)
                                kind: modelData.item.kind
                                options: modelData.item.options || []
                                labels: root.optionLabels(modelData.item)
                                presets: modelData.item.presets || []
                                maxLength: modelData.item.maxLength !== undefined ? modelData.item.maxLength : 256
                                min: modelData.item.min !== undefined ? modelData.item.min : 0
                                max: modelData.item.max !== undefined ? modelData.item.max : 100
                                step: modelData.item.step !== undefined ? modelData.item.step : 1
                                unit: modelData.item.unit || ""
                                defaultValue: modelData.item.fallback
                                dimmed: root.dimmed(modelData.item)
                                value: root.val(modelData.item.key)
                                onEdited: function(v) { root.setValue(modelData.item.key, v) }
                            }
                        }
                    }
                }
            }
        }

        // ---- footer ---------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: theme.tint(0.10)
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: theme.px(8)

            Txt {
                ui: theme
                text: root.changedCount === 0
                    ? root.t("panel.defaults", "All defaults")
                    : root.t("panel.changed", "%1 changed").arg(root.changedCount)
                font.pixelSize: theme.fs(10)
                opacity: 0.5
            }

            Item { Layout.fillWidth: true }

            Btn {
                ui: theme
                text: root.confirmReset
                    ? root.t("panel.resetConfirm", "Click again to reset")
                    : root.t("panel.reset", "Reset")
                kind: "normal"
                active: root.confirmReset
                onClicked: root.resetAll()
            }

            Btn {
                ui: theme
                visible: root.popped
                text: root.t("panel.dock", "Dock to bar")
                onClicked: root.dockRequested()
            }

            Btn {
                ui: theme
                visible: !root.popped
                text: root.t("panel.popOut", "Own window")
                onClicked: root.popOutRequested()
            }
        }
    }
}
