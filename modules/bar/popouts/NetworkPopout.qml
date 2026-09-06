pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Configs
import qs.services
import qs.components

// WiFi 弹出面板：开关 + 当前连接 + 扫描 + 网络列表 + 密码连接
Item {
    id: root

    property int maxHeight: 0

    readonly property int padding: Config.appearance.padding.normal
    readonly property int rowRadius: 10

    property string pendingSsid: ""

    implicitWidth: 360
    implicitHeight: Math.min(column.implicitHeight + padding * 2, root.maxHeight)

    function connect(ssid: string, security: string): void {
        if (security === "--" || security === "none") {
            Network.connectToNetwork(ssid, "");
            root.pendingSsid = "";
        } else {
            root.pendingSsid = ssid;
        }
    }

    ColumnLayout {
        id: column

        anchors.centerIn: parent
        width: parent.width - root.padding * 2
        spacing: Config.appearance.spacing.smaller

        // ==== 开关 + 当前连接 ====
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            radius: root.rowRadius
            color: Theme.surface0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 10

                MaterialSymbol {
                    text: Network.materialSymbol
                    size: 22
                    color: Network.wifiStatus === "connected" ? Theme.green : Network.wifiEnabled ? Theme.subtext1 : Theme.danger
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: Network.wifiEnabled ? (Network.networkName && Network.networkName !== "lo" ? Network.networkName : "未连接") : "WiFi 已关闭"
                        color: Theme.text
                        font.pixelSize: 13
                        font.bold: true
                        elide: Text.ElideRight

                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: {
                            if (!Network.wifiEnabled)
                                return "点击右侧开关开启";
                            if (Network.isScanning)
                                return "正在扫描...";
                            if (Network.wifiStatus === "connecting")
                                return "正在连接...";
                            if (Network.networkName && Network.networkName !== "lo")
                                return `信号 ${Network.networkStrength}%`;
                            return "选择下方网络以连接";
                        }
                        color: Theme.subtext1
                        font.pixelSize: 11

                        Layout.fillWidth: true
                    }
                }

                StyledSwitch {
                    checked: Network.wifiEnabled
                    onToggled: checked => {
                        Network.enableWifi(checked);
                        if (checked)
                            Network.scanNetworks();
                    }
                }
            }
        }

        // ==== 密码输入 ====
        Rectangle {
            visible: root.pendingSsid !== ""
            Layout.fillWidth: true
            implicitHeight: 44
            radius: root.rowRadius
            color: Theme.surface0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                spacing: 8

                MaterialSymbol {
                    text: "lock"
                    size: 18
                    color: Theme.overlay0
                }

                StyledTextInput {
                    id: passwordInput

                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholderText: `输入 "${root.pendingSsid}" 的密码`
                    font.pixelSize: 12

                    onAccepted: {
                        Network.connectToNetwork(root.pendingSsid, text);
                        root.pendingSsid = "";
                        text = "";
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 28
                    radius: 8
                    color: connectArea.containsMouse ? Theme.mauve : Theme.surface1

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "arrow_forward"
                        size: 16
                        color: connectArea.containsMouse ? Theme.onPrimary : Theme.text
                    }

                    MouseArea {
                        id: connectArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Network.connectToNetwork(root.pendingSsid, passwordInput.text);
                            root.pendingSsid = "";
                            passwordInput.text = "";
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 28
                    radius: 8
                    color: cancelArea.containsMouse ? Theme.surface2 : "transparent"

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "close"
                        size: 16
                        color: Theme.overlay0
                    }

                    MouseArea {
                        id: cancelArea

                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.pendingSsid = "";
                            passwordInput.text = "";
                        }
                    }
                }
            }
        }

        // ==== 网络列表 ====
        ListView {
            id: networkList

            visible: Network.wifiEnabled
            Layout.fillWidth: true

            implicitHeight: {
                const desired = contentHeight;
                const available = root.maxHeight - 52 - Config.appearance.spacing.smaller * 2 - root.padding * 2;
                return Math.min(desired, Math.max(available, 0));
            }
            clip: true
            spacing: Config.appearance.spacing.small / 2
            interactive: contentHeight > height

            model: Network.availableNetworks

            delegate: Rectangle {
                id: networkRow

                required property var modelData

                width: networkList.width
                height: 38
                radius: root.rowRadius
                color: hoverHandler.hovered ? Theme.surface1 : Theme.surface0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    MaterialSymbol {
                        text: {
                            const s = networkRow.modelData.signal;
                            if (s > 80)
                                return "signal_wifi_4_bar";
                            if (s > 60)
                                return "network_wifi_3_bar";
                            if (s > 40)
                                return "network_wifi_2_bar";
                            if (s > 20)
                                return "network_wifi_1_bar";
                            return "signal_wifi_0_bar";
                        }
                        size: 18
                        color: networkRow.modelData.ssid === Network.networkName ? Theme.green : Theme.subtext1
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: networkRow.modelData.ssid
                        color: Theme.text
                        font.pixelSize: 13
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: networkRow.modelData.signal + "%"
                        color: Theme.overlay0
                        font.pixelSize: 11
                    }

                    MaterialSymbol {
                        text: networkRow.modelData.security !== "--" ? "lock" : ""
                        size: 14
                        color: Theme.overlay0
                    }

                    MaterialSymbol {
                        text: networkRow.modelData.ssid === Network.networkName ? "check_circle" : ""
                        size: 16
                        color: Theme.green
                    }
                }

                HoverHandler {
                    id: hoverHandler
                }

                TapHandler {
                    onTapped: root.connect(networkRow.modelData.ssid, networkRow.modelData.security)
                }
            }
        }

        // ==== 底部操作 ====
        RowLayout {
            visible: Network.wifiEnabled
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredHeight: 28
                Layout.preferredWidth: rowLayout.implicitWidth + 20
                radius: 8
                color: refreshArea.containsMouse ? Theme.surface2 : Theme.surface1

                RowLayout {
                    id: rowLayout

                    anchors.centerIn: parent
                    spacing: 6

                    MaterialSymbol {
                        text: "refresh"
                        size: 14
                        color: Theme.text
                    }

                    StyledText {
                        text: "重新扫描"
                        color: Theme.text
                        font.pixelSize: 12
                    }
                }

                MouseArea {
                    id: refreshArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Network.scanNetworks()
                }
            }
        }
    }

    Connections {
        target: Network

        function onConnectFailed(ssid: string): void {
            root.pendingSsid = ssid;
        }
    }
}