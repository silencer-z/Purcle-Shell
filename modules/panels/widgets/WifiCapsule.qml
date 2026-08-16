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
        color: Theme.surface0
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 8

        // WiFi图标
        MaterialSymbol {
            text: Network.materialSymbol
            size: 24
            color: Network.networkName.length > 0 && Network.networkName !== "lo" ? Theme.green : Theme.danger
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
                color: Theme.text
                elide: Text.ElideRight
            }

            StyledText {
                text: Network.networkName.length > 0 && Network.networkName !== "lo" ? `信号: ${Network.networkStrength}%` : "无网络连接"
                font.pixelSize: 11
                color: Theme.subtext1
            }

        }

        // 展开/收起按钮
        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 15
            color: expanded ? Theme.blue : Theme.surface1

            MaterialSymbol {
                anchors.centerIn: parent
                text: expanded ? "keyboard_arrow_up" : "keyboard_arrow_down"
                size: 18
                color: Theme.text
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    parent.color = expanded ? Theme.sky : Theme.surface2;
                }
                onExited: {
                    parent.color = expanded ? Theme.blue : Theme.surface1;
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
