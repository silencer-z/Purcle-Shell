import QtQuick
import qs.components

Rectangle {
    id: root

    color: "transparent"

    Behavior on color {
        ColorAnim {}
    }
}
