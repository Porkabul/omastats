import QtQuick
import qs.Commons

// Theme + spacing for the settings panel. Kept in one object so the panel and
// the reusable controls agree on names and on what a "tint" means.
QtObject {
    id: root

    property real surfaceOpacity: 1.0

    readonly property color surface: Qt.rgba(Color.popups.background.r,
                                             Color.popups.background.g,
                                             Color.popups.background.b, 1)
    readonly property color panelColor: Qt.rgba(surface.r, surface.g, surface.b,
                                                Math.max(0.35, Math.min(1, surfaceOpacity)))
    readonly property color fg: Color.popups.text
    readonly property color accent: Color.accent
    readonly property color urgent: Color.urgent
    readonly property color muted: Color.muted
    readonly property color bad: Color.urgent
    readonly property string fontName: Style.font.family
    readonly property bool animations: true

    function lumOf(c) { return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b }

    function contrast(c) {
        return lumOf(c) > 0.5 ? Qt.rgba(0.08, 0.08, 0.09, 1)
                              : Qt.rgba(0.96, 0.96, 0.97, 1)
    }

    function tint(a) { return Qt.rgba(fg.r, fg.g, fg.b, a) }
    function accentTint(a) { return Qt.rgba(accent.r, accent.g, accent.b, a) }

    function mix(a, b, t) {
        return Qt.rgba(a.r * (1 - t) + b.r * t,
                       a.g * (1 - t) + b.g * t,
                       a.b * (1 - t) + b.b * t, 1)
    }

    function onFill(c) { return mix(surface, c, 0.22) }
    function onText(c) { return contrast(onFill(c)) }

    readonly property color accentText: contrast(accent)

    function r(k) { return Math.max(0, Math.round(Number(k) * 4)) }
    function fs(n) { return Math.max(8, Math.round(Number(n) * Style.fontScale)) }
    function px(n) { return Math.max(0, Math.round(Style.spaceReal(Number(n)))) }
}
