import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services

// Aylur toggle-button 风格 WiFi 胶囊：连接时 primary 填充，未连接时 surface + inset 边框
Item {
    id: root

    property bool expanded: false
    property var closeCallback: null

    readonly property bool connected: Network.wifiStatus === "connected" && Network.networkName.length > 0 && Network.networkName !== "lo"

    implicitWidth: 500
    implicitHeight: 60

    WifiPopupPanel {
        id: wifiPopup
        targetItem: root
        visible: root.expanded
    }

    Rectangle {
        id: capsule

        anchors.fill: parent
        radius: 14
        color: root.connected ? Theme.mauve : capsuleHover.hovered ? Theme.surface1 : Theme.surface0
        border.width: root.connected ? 0 : 1
        border.color: Theme.surface2

        Behavior on color {
            ColorAnim {}
        }

        Behavior on border.color {
            ColorAnim {}
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // WiFi图标
        MaterialSymbol {
            text: Network.materialSymbol
            size: 24
            color: root.connected ? Theme.onPrimary : root.connected || Network.wifiEnabled ? Theme.green : Theme.danger
            Layout.preferredWidth: 30
        }

        // 连接信息
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                text: root.connected ? Network.networkName : "未连接"
                font.pixelSize: 14
                font.bold: true
                color: root.connected ? Theme.onPrimary : Theme.text
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnim {}
                }
            }

            StyledText {
                text: root.connected ? `信号: ${Network.networkStrength}%` : Network.wifiEnabled ? "无网络连接" : "WiFi 已关闭"
                font.pixelSize: 11
                color: root.connected ? Qt.alpha(Theme.onPrimary, 0.75) : Theme.subtext1

                Behavior on color {
                    ColorAnim {}
                }
            }

        }

        // 展开/收起箭头
        MaterialSymbol {
            text: root.expanded ? "keyboard_arrow_up" : "keyboard_arrow_down"
            size: 20
            color: root.connected ? Theme.onPrimary : Theme.overlay0
        }
    }

    HoverHandler {
        id: capsuleHover
    }

    TapHandler {
        onTapped: {
            root.expanded = !root.expanded;
            if (root.expanded && Network.availableNetworksCount === 0) {
                Network.scanNetworks();
            }
        }
    }
}