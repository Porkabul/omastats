import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "panel"

// Docked settings: the same SettingsView as the floating window, hung under
// the bar in a KeyboardPanel. The bar button owns open/close; this file only
// provides the surface and the size.
Panel {
    id: root

    moduleName: "io.github.porkabul.omastats"
    ipcTarget: ""
    manageIpc: false

    property var store: null
    property var cfg: ({})
    property var strings: null
    property var anchorItem: null
    property var hostWidget: null

    readonly property var barIdentity: hostWidget || root

    function cfgValue(key, fallback) {
        return root.cfg && root.cfg[key] !== undefined ? root.cfg[key] : fallback
    }

    KeyboardPanel {
        id: panel
        anchorItem: root.anchorItem || root
        owner: root.barIdentity
        bar: root.bar
        open: root.opened
        centerOnBar: true
        focusTarget: settingsView
        contentWidth: panel.fittedContentWidth(Math.round(root.cfgValue("panelWidth", 560)))
        contentHeight: panel.fittedContentHeight(Math.round(root.cfgValue("panelHeight", 640)))

        SettingsView {
            id: settingsView
            anchors.fill: parent
            store: root.store
            cfg: root.cfg
            strings: root.strings
            popped: false
            onCloseRequested: root.close()
            onPopOutRequested: {
                if (root.hostWidget && typeof root.hostWidget.popOut === "function")
                    root.hostWidget.popOut()
            }
        }
    }
}
