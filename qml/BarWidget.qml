import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "js/Schema.js" as Schema
import "js/Format.js" as Format
import "core"
import "components"

// CPU, GPU, memory, disks and network in the bar. Left or right click opens
// the settings panel; middle click can run btop. Every value comes from the
// small collector in bin/omastats, one JSON object per interval.
BarWidget {
    id: root

    moduleName: "io.github.porkabul.omastats"

    SettingsStore { id: store }
    Translations { id: strings; directory: Qt.resolvedUrl("../i18n") }

    readonly property var cfg: Schema.resolve(root.settings, store.values)
    readonly property color fg: bar ? bar.barForeground : Color.foreground
    readonly property string fontName: bar ? bar.fontFamily : Style.font.family
    readonly property real fontSize: Style.font.body * (Number(cfg.fontScale) / 100)

    property var stats: ({})
    property bool ready: false
    property string lastSignature: ""

    readonly property string scriptPath: Qt.resolvedUrl("../bin/omastats").toString().replace(/^file:\/\//, "")

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    function has(v) { return v !== null && v !== undefined && v !== "" }

    function colorFor(value, warn, crit) {
        const t = Format.thresholds(warn, crit)
        return Format.colorFor(value, t.warn, t.crit, cfg)
    }

    // 0 low, 1 middle, 2 high. Used to let a hot CPU keep the bar green while
    // its temperature turns the value amber or red.
    function levelFor(value, warn, crit) {
        const t = Format.thresholds(warn, crit)
        const v = Number(value)
        if (!isFinite(v)) return 0
        return v >= t.crit ? 2 : (v >= t.warn ? 1 : 0)
    }

    function rampColor(level) {
        return level >= 2 ? cfg.colorHigh : (level >= 1 ? cfg.colorMid : cfg.colorLow)
    }

    // Every reading the bar should draw, in a stable order. A value this
    // machine cannot read never becomes a fake zero: it is simply absent.
    readonly property var metrics: {
        const out = []
        const d = root.stats || {}
        const c = root.cfg

        if (c.cpuShow && has(d.cpu)) {
            const loadCol = colorFor(d.cpu, c.cpuWarn, c.cpuCrit)
            let level = levelFor(d.cpu, c.cpuWarn, c.cpuCrit)
            let text = Format.pct(d.cpu, c.showUnits)
            if (c.cpuTempShow && has(d.cpuTemp)) {
                text += " " + Format.temp(d.cpuTemp, c.showUnits)
                if (c.colorExtra)
                    level = Math.max(level, levelFor(d.cpuTemp, c.cpuTempWarn, c.cpuTempCrit))
            }
            out.push({
                key: "cpu", label: "CPU", short: "C",
                valueText: text,
                fraction: Format.fraction(d.cpu, c.cpuMin, c.cpuMax),
                color: loadCol,
                valueColor: c.colorText ? (c.colorExtra ? rampColor(level) : loadCol) : root.fg
            })
            // Bars-only hides the value line. Keep the temperature readable as
            // its own bar, marked with a degree sign instead of repeating "CPU".
            if (c.display === "bar" && c.cpuTempShow && has(d.cpuTemp)) {
                const tempCol = c.colorExtra ? colorFor(d.cpuTemp, c.cpuTempWarn, c.cpuTempCrit) : root.fg
                out.push({
                    key: "cpuTemp", label: "\u00b0", short: "\u00b0",
                    valueText: "",
                    fraction: Format.fraction(d.cpuTemp, c.cpuTempMin, c.cpuTempMax),
                    color: tempCol, valueColor: root.fg
                })
            }
        }

        const hasGpu = has(d.gpu) || has(d.gpuTemp)
        if (c.gpuShow && hasGpu) {
            if (has(d.gpu)) {
                const loadCol = colorFor(d.gpu, c.gpuWarn, c.gpuCrit)
                let level = levelFor(d.gpu, c.gpuWarn, c.gpuCrit)
                let text = Format.pct(d.gpu, c.showUnits)
                if (c.gpuTempShow && has(d.gpuTemp)) {
                    text += " " + Format.temp(d.gpuTemp, c.showUnits)
                    if (c.colorExtra)
                        level = Math.max(level, levelFor(d.gpuTemp, c.gpuTempWarn, c.gpuTempCrit))
                }
                out.push({
                    key: "gpu", label: "GPU", short: "G",
                    valueText: text,
                    fraction: Format.fraction(d.gpu, c.gpuMin, c.gpuMax),
                    color: loadCol,
                    valueColor: c.colorText ? (c.colorExtra ? rampColor(level) : loadCol) : root.fg
                })
                if (c.display === "bar" && c.gpuTempShow && has(d.gpuTemp)) {
                    const tempCol = c.colorExtra ? colorFor(d.gpuTemp, c.gpuTempWarn, c.gpuTempCrit) : root.fg
                    out.push({
                        key: "gpuTemp", label: "\u00b0", short: "\u00b0",
                        valueText: "",
                        fraction: Format.fraction(d.gpuTemp, c.gpuTempMin, c.gpuTempMax),
                        color: tempCol, valueColor: root.fg
                    })
                }
            }
        }

        if (c.ramShow && has(d.ram)) {
            const col = colorFor(d.ram, c.ramWarn, c.ramCrit)
            out.push({
                key: "ram", label: "RAM", short: "M",
                valueText: Format.pct(d.ram, c.showUnits),
                fraction: Format.fraction(d.ram, c.ramMin, c.ramMax),
                color: col, valueColor: c.colorText ? col : root.fg
            })
        }

        if (c.swapShow && has(d.swap) && Number(d.swapTotal) > 0) {
            const col = colorFor(d.swap, c.swapWarn, c.swapCrit)
            out.push({
                key: "swap", label: "SWP", short: "S",
                valueText: Format.pct(d.swap, c.showUnits),
                fraction: Format.fraction(d.swap, c.swapMin, c.swapMax),
                color: col, valueColor: c.colorText ? col : root.fg
            })
        }

        if (c.diskShow && Array.isArray(d.disks) && d.disks.length > 0) {
            let list = d.disks
            if (c.diskMode === "max") {
                const best = Format.fullestDisk(list)
                list = best ? [best] : []
            }
            for (let i = 0; i < list.length; i++) {
                const disk = list[i]
                const col = colorFor(disk.pct, c.diskWarn, c.diskCrit)
                out.push({
                    key: "disk:" + String(disk.mount),
                    label: Format.diskLabel(disk.mount), short: "D",
                    valueText: Format.pct(disk.pct, c.showUnits),
                    fraction: Format.fraction(disk.pct, c.diskMin, c.diskMax),
                    color: col, valueColor: c.colorText ? col : root.fg
                })
            }
        }

        if (c.netShow && has(d.iface)) {
            const t = Format.thresholds(c.netWarn, c.netCrit)
            if (c.netRxShow && has(d.rx)) {
                const mb = Format.mbps(d.rx)
                const col = Format.colorFor(mb, t.warn, t.crit, c)
                out.push({
                    key: "rx", label: "\u2193", short: "\u2193",
                    valueText: Format.rate(d.rx, c.netUnit, c.netDecimals),
                    fraction: Format.fraction(mb, c.netMin, c.netMax),
                    color: col, valueColor: c.colorText ? col : root.fg
                })
            }
            if (c.netTxShow && has(d.tx)) {
                const mb = Format.mbps(d.tx)
                const col = Format.colorFor(mb, t.warn, t.crit, c)
                out.push({
                    key: "tx", label: "\u2191", short: "\u2191",
                    valueText: Format.rate(d.tx, c.netUnit, c.netDecimals),
                    fraction: Format.fraction(mb, c.netMin, c.netMax),
                    color: col, valueColor: c.colorText ? col : root.fg
                })
            }
        }

        return out
    }

    readonly property bool miniVertical: !vertical && cfg.barOrientation === "vertical"

    function tip(key, fallback) { return strings.t(key, fallback) }

    readonly property string tooltipText: {
        const d = root.stats || {}
        const c = root.cfg
        const lines = []
        if (!c.tooltip) return ""
        if (c.cpuShow && has(d.cpu)) {
            let line = tip("tip.cpu", "CPU") + "  " + Format.pct(d.cpu, true)
            if (c.cpuTempShow && has(d.cpuTemp)) line += "  " + Format.temp(d.cpuTemp, true)
            lines.push(line)
        }
        const hasGpu = has(d.gpu) || has(d.gpuTemp)
        if (c.gpuShow && hasGpu) {
            let line = tip("tip.gpu", "GPU")
            if (has(d.gpu)) line += "  " + Format.pct(d.gpu, true)
            if (c.gpuTempShow && has(d.gpuTemp)) line += "  " + Format.temp(d.gpuTemp, true)
            lines.push(line)
        }
        if (c.ramShow && has(d.ram)) {
            let line = tip("tip.ram", "RAM") + "  " + Format.pct(d.ram, true)
            if (has(d.ramUsed) && has(d.ramTotal))
                line += "  " + Format.gib(d.ramUsed) + " / " + Format.gib(d.ramTotal) + " GiB"
            lines.push(line)
        }
        if (c.swapShow && has(d.swap) && Number(d.swapTotal) > 0) {
            let line = tip("tip.swap", "Swap") + "  " + Format.pct(d.swap, true)
            if (has(d.swapUsed) && has(d.swapTotal))
                line += "  " + Format.gib(d.swapUsed) + " / " + Format.gib(d.swapTotal) + " GiB"
            lines.push(line)
        }
        if (c.diskShow && Array.isArray(d.disks)) {
            for (let i = 0; i < d.disks.length; i++) {
                const disk = d.disks[i]
                let line = tip("tip.disk", "Disk") + " " + String(disk.mount) + "  " + Format.pct(disk.pct, true)
                if (has(disk.used) && has(disk.total))
                    line += "  " + Format.gib(disk.used) + " / " + Format.gib(disk.total) + " GiB"
                lines.push(line)
            }
        }
        if (c.netShow && has(d.iface)) {
            let line = String(d.iface)
            if (c.netRxShow && has(d.rx)) line += "  \u2193 " + Format.rate(d.rx, c.netUnit, c.netDecimals)
            if (c.netTxShow && has(d.tx)) line += "  \u2191 " + Format.rate(d.tx, c.netUnit, c.netDecimals)
            lines.push(line)
        }
        return lines.join("\n")
    }

    function ingest(line) {
        const text = String(line || "").trim()
        if (text === "") return
        try {
            const obj = JSON.parse(text)
            if (obj && typeof obj === "object" && !Array.isArray(obj)) {
                root.stats = obj
                root.ready = true
            }
        } catch (e) { }
    }

    function signature() {
        return String(cfg.interval) + "|" + String(cfg.netInterface) + "|" + String(cfg.diskMounts)
    }

    function restartCollector() {
        statsProc.running = false
        restartNow.restart()
    }

    function openPanel() {
        if (panelLoader.item) panelLoader.item.open()
    }
    function openWindow() {
        if (popoutLoader.item) popoutLoader.item.open()
    }
    function open() {
        if (cfg.openAs === "window") {
            if (panelLoader.item) panelLoader.item.close()
            openWindow()
        } else {
            if (popoutLoader.item) popoutLoader.item.close()
            openPanel()
        }
    }
    function close() {
        if (panelLoader.item) panelLoader.item.close()
        if (popoutLoader.item) popoutLoader.item.close()
    }
    function toggle() { if (root.opened) root.close(); else root.open() }

    readonly property bool opened: (panelLoader.item ? panelLoader.item.opened === true : false)
        || (popoutLoader.item ? popoutLoader.item.opened === true : false)

    function popOut() {
        if (panelLoader.item) panelLoader.item.close()
        if (popoutLoader.item) popoutLoader.item.open()
    }
    function dockBack() {
        if (popoutLoader.item) popoutLoader.item.close()
        if (panelLoader.item) panelLoader.item.open()
    }

    function injectPanel() {
        const target = panelLoader.item
        if (!target) return
        target.bar = root.bar
        target.anchorItem = button
        target.store = store
        target.strings = strings
        target.cfg = Qt.binding(function() { return root.cfg })
    }

    function injectPopout() {
        const target = popoutLoader.item
        if (!target) return
        target.store = store
        target.strings = strings
        target.cfg = Qt.binding(function() { return root.cfg })
    }

    onBarChanged: { injectPanel(); injectPopout() }
    onSettingsChanged: injectPanel()
    onCfgChanged: {
        const sig = signature()
        if (lastSignature !== "" && sig !== lastSignature) restartCollector()
        lastSignature = sig
    }
    Component.onCompleted: lastSignature = signature()

    Process {
        id: statsProc
        running: true
        command: [root.scriptPath, String(root.cfg.interval), String(root.cfg.netInterface), String(root.cfg.diskMounts)]
        stdout: SplitParser { onRead: function(line) { root.ingest(line) } }
        onExited: restartTimer.restart()
    }

    Timer {
        id: restartTimer
        interval: 3000
        onTriggered: statsProc.running = true
    }

    Timer {
        id: restartNow
        interval: 60
        onTriggered: statsProc.running = true
    }

    Loader {
        id: panelLoader
        active: true
        visible: false
        source: "PanelHost.qml"
        onLoaded: root.injectPanel()
    }

    Loader {
        id: popoutLoader
        active: true
        visible: false
        source: "panel/PopoutWindow.qml"
        onLoaded: {
            root.injectPopout()
            if (popoutLoader.item && popoutLoader.item.dockRequested)
                popoutLoader.item.dockRequested.connect(root.dockBack)
        }
    }

    IpcHandler {
        target: "omastats"

        function open(): void { root.open() }
        function close(): void { root.close() }
        function show(): void { root.open() }
        function hide(): void { root.close() }
        function toggle(): void { root.toggle() }
        function refresh(): void { root.restartCollector() }
    }

    WidgetButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        text: ""
        labelVisible: false
        hasVisualContent: root.ready && root.metrics.length > 0
        horizontalMargin: 8.75
        verticalPadding: 6
        fixedWidth: root.vertical
            ? -1
            : (root.metrics.length > 0 ? horizontalRow.implicitWidth + Style.space(18) : 0)
        fixedHeight: root.vertical
            ? (root.metrics.length > 0 ? verticalCol.implicitHeight + Style.space(6) : 0)
            : -1
        tooltipText: root.tooltipText

        onPressed: function(b) {
            if (b === Qt.MiddleButton) {
                if (root.cfg.clickAction === "btop" && root.bar)
                    root.bar.run("omarchy-launch-or-focus-tui btop")
                return
            }
            root.toggle()
        }

        Row {
            id: horizontalRow
            visible: !root.vertical
            anchors.centerIn: parent
            spacing: root.cfg.gap

            Repeater {
                model: root.vertical ? [] : root.metrics
                delegate: MetricChip {
                    required property var modelData
                    required property int index

                    label: modelData.label
                    shortLabel: modelData.short
                    valueText: modelData.valueText
                    fraction: modelData.fraction
                    fillColor: modelData.color
                    valueColor: modelData.valueColor
                    showBar: root.cfg.display !== "text"
                    showLabel: root.cfg.labels
                    showValue: root.cfg.display !== "bar"
                    compact: false
                    verticalBar: root.miniVertical
                    barLength: root.cfg.barLength
                    barThickness: root.cfg.barThickness
                    rounding: root.cfg.barRounding
                    trackColor: Qt.rgba(modelData.color.r, modelData.color.g,
                                        modelData.color.b, Number(root.cfg.barTrackOpacity) / 100)
                    textColor: root.fg
                    fontFamily: root.fontName
                    fontSize: root.fontSize
                    separator: root.cfg.separator
                    showSeparator: root.cfg.labels && index < root.metrics.length - 1
                }
            }
        }

        Column {
            id: verticalCol
            visible: root.vertical
            anchors.centerIn: parent
            spacing: Math.max(1, root.cfg.gap)

            Repeater {
                model: root.vertical ? root.metrics : []
                delegate: MetricChip {
                    required property var modelData
                    required property int index

                    label: modelData.label
                    shortLabel: modelData.short
                    valueText: modelData.valueText
                    fraction: modelData.fraction
                    fillColor: modelData.color
                    valueColor: modelData.valueColor
                    showBar: root.cfg.display !== "text"
                    showLabel: root.cfg.labels
                    showValue: false
                    compact: true
                    verticalBar: false
                    barLength: Math.min(14, root.cfg.barLength)
                    barThickness: root.cfg.barThickness
                    rounding: root.cfg.barRounding
                    trackColor: Qt.rgba(modelData.color.r, modelData.color.g,
                                        modelData.color.b, Number(root.cfg.barTrackOpacity) / 100)
                    textColor: root.fg
                    fontFamily: root.fontName
                    fontSize: Math.max(8, root.fontSize - 1)
                    separator: ""
                    showSeparator: false
                }
            }
        }
    }
}
