import QtQuick
import qs.Configs
import qs.components as Components
import qs.services

Components.BarWidget {
    id: root

    color: "transparent"
    paddingLeft: 0
    paddingRight: 0

    property bool hovered: false

    // Logo 按钮：点击打开启动器
    Components.MaterialSymbol {
        id: icon
        anchors.centerIn: parent
        text: "planet"
        font.pixelSize: Config.appearance.fonts.size.icon
        opacity: root.hovered ? 1 : 0.75

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: Visibilities.togglePanel("launcher")
    }
}
