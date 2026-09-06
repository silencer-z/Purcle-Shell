import QtQuick
import QtQuick.Controls
import qs.services

TextInput {
    id: root

    property string placeholderText: ""
    property color placeholderColor: Theme.overlay0

    renderType: Text.NativeRendering
    selectedTextColor: Theme.onPrimary
    selectionColor: Theme.mauve

    font {
        family: "更纱终端书呆简体-黑"
        pixelSize: 18
        hintingPreference: Font.PreferFullHinting
    }

    Text {
        anchors.fill: parent
        visible: root.text === "" && root.placeholderText !== ""
        text: root.placeholderText
        color: root.placeholderColor
        font: root.font
        verticalAlignment: root.verticalAlignment
        elide: Text.ElideRight
    }

}