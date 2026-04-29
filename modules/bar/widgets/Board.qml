import QtQuick
import "root:/components" as Components

Components.BarWidget {
    id: root

    color: "transparent"
    // padding:0
    paddingLeft: 0
    paddingRight: 0

    Components.MaterialSymbol {
        anchors.fill: parent
        text: "planet"
        font.pixelSize: 21
    }

}
