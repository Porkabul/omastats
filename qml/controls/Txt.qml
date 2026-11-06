import QtQuick

// All panel text goes through here. Plain text only: settings values and
// mount points are data, never markup.
Text {
    property var ui: null

    textFormat: Text.PlainText
    color: ui ? ui.fg : "white"
    font.family: ui ? ui.fontName : ""
    font.pixelSize: ui ? ui.fs(11) : 11
}
