import QtQuick
import Quickshell

// The settings as a window of their own: move, resize and tile them. The title
// is "OmaStats", for window rules.
FloatingWindow {
    id: win

    property var store: null
    property var cfg: ({})
    property var strings: null
    property bool opened: false

    signal dockRequested()

    title: "OmaStats"
    visible: false
    color: "transparent"
    implicitWidth: cfg && cfg.panelWidth !== undefined ? Number(cfg.panelWidth) : 560
    implicitHeight: cfg && cfg.panelHeight !== undefined ? Number(cfg.panelHeight) : 640
    // A tiling window manager may ignore the implicit size; keep the rows and
    // their controls from being squeezed past use.
    minimumSize: Qt.size(420, 360)

    function open() {
        visible = true
        opened = true
    }

    function close() {
        visible = false
        opened = false
    }

    onVisibleChanged: if (!visible) opened = false

    SettingsView {
        anchors.fill: parent
        store: win.store
        cfg: win.cfg
        strings: win.strings
        popped: true
        onCloseRequested: win.close()
        onDockRequested: {
            win.close()
            win.dockRequested()
        }
    }
}
