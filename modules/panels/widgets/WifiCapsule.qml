import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services

Item {
    id: root

    property bool expanded: false
    property var closeCallback: null

    implicitWidth: 500
    implicitHeight: 60

    // Wifi Popup Window
    WifiPopupPanel {
        id: wifiPopup
        targetItem: root
        visible: root.expanded
    }

    Rectangle {
        id: capsule

        anchors.fill: parent
        radius: 20
        color: "#313244"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 8

        // WiFi图标
        IconText {
            text: Network.materialSymbol
            size: 24
            color: Network.networkName.length > 0 && Network.networkName !== "lo" ? "#a6e3a1" : "#f38ba8"
            Layout.preferredWidth: 30
        }

        // 连接信息
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                text: Network.networkName.length > 0 && Network.networkName !== "lo" ? Network.networkName : "未连接"
                font.pixelSize: 14
                font.bold: true
                color: "#cdd6f4"
                elide: Text.ElideRight
            }

            StyledText {
                text: Network.networkName.length > 0 && Network.networkName !== "lo" ? `信号: ${Network.networkStrength}%` : "无网络连接"
                font.pixelSize: 11
                color: "#a6adc8"
            }

        }

        // 展开/收起按钮
        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 15
            color: expanded ? "#89b4fa" : "#45475a"

            IconText {
                anchors.centerIn: parent
                text: expanded ? "keyboard_arrow_up" : "keyboard_arrow_down"
                size: 18
                color: "#cdd6f4"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    parent.color = expanded ? "#74c7ec" : "#585b70";
                }
                onExited: {
                    parent.color = expanded ? "#89b4fa" : "#45475a";
                }
                onClicked: {
                    expanded = !expanded;
                    if (expanded && Network.availableNetworksCount === 0) {
                        Network.scanNetworks();
                    }
                }
            }
        }
    }
}
