pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Configs
import qs.components
import qs.services

// 连接区：WiFi / 蓝牙（展开列表互斥）
PanelWidget {
    id: root

    readonly property int rowRadius: 10
    readonly property int rowHeight: 44
    readonly property int listMaxHeight: 220

    property bool wifiExpanded: false
    property bool btExpanded: false
    // WiFi 密码连接待验证 SSID
    property string pendingSsid: ""

    color: Theme.surface0

    Behavior on color {
        ColorAnim {}
    }

    implicitHeight: rows.implicitHeight + Config.appearance.padding.normal * 2

    onWifiExpandedChanged: if (wifiExpanded)
        btExpanded = false
    onBtExpandedChanged: if (btExpanded)
        wifiExpanded = false

    ColumnLayout {
        id: rows

        anchors.fill: parent
        spacing: Config.appearance.spacing.small / 2

        // ================= WiFi =================
        // ==== 开关行 ====
        Rectangle {
            id: wifiRow

            Layout.fillWidth: true
            implicitHeight: root.rowHeight
            radius: root.rowRadius
            color: wifiTap.hovered ? Theme.surface1 : "transparent"

            Behavior on color {
                ColorAnim {}
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 10

                MaterialSymbol {
                    text: Network.materialSymbol
                    size: 20
                    color: Network.wifiStatus === "connected" ? Theme.green : Network.wifiEnabled ? Theme.subtext1 : Theme.danger
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: Network.wifiEnabled ? (Network.networkName && Network.networkName !== "lo" ? Network.networkName : qsTr("未连接")) : qsTr("WiFi 已关闭")
                        color: Theme.text
                        font.pixelSize: Config.appearance.fonts.size.medium
                        font.bold: true
                        elide: Text.ElideRight

                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: {
                            if (!Network.wifiEnabled)
                                return qsTr("点击开关开启");
                            if (Network.isScanning)
                                return qsTr("正在扫描...");
                            if (Network.wifiStatus === "connecting")
                                return qsTr("正在连接...");
                            if (Network.networkName && Network.networkName !== "lo")
                                return qsTr("信号 %1%").arg(Network.networkStrength);
                            return qsTr("选择下方网络以连接");
                        }
                        color: Theme.subtext1
                        font.pixelSize: Config.appearance.fonts.size.tiny

                        Layout.fillWidth: true
                    }
                }

                MaterialSymbol {
                    text: root.wifiExpanded ? "keyboard_arrow_up" : "keyboard_arrow_down"
                    size: 18
                    color: Theme.overlay0

                    TapHandler {
                        onTapped: root.wifiExpanded = !root.wifiExpanded
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

            // 点击行体（非开关区域）展开
            TapHandler {
                id: wifiTap

                onTapped: root.wifiExpanded = !root.wifiExpanded
            }
        }

        // ==== 网络列表 ====
        ColumnLayout {
            visible: root.wifiExpanded && Network.wifiEnabled
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small / 2

            Behavior on implicitHeight {
                NumberAnim {}
            }

            // 密码输入
            Rectangle {
                visible: root.pendingSsid !== ""
                Layout.fillWidth: true
                implicitHeight: 40
                radius: root.rowRadius
                color: Theme.surface1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 8
                    spacing: 8

                    MaterialSymbol {
                        text: "lock"
                        size: 16
                        color: Theme.overlay0
                    }

                    StyledTextInput {
                        id: passwordInput

                        Layout.fillWidth: true
                        echoMode: TextInput.Password
                        placeholderText: qsTr("输入 \"%1\" 的密码").arg(root.pendingSsid)
                        font.pixelSize: Config.appearance.fonts.size.small

                        onAccepted: {
                            Network.connectToNetwork(root.pendingSsid, text);
                            root.pendingSsid = "";
                            text = "";
                        }
                    }

                    MaterialSymbol {
                        text: "arrow_forward"
                        size: 16
                        color: connectArea.containsMouse ? Theme.mauve : Theme.text

                        MouseArea {
                            id: connectArea

                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Network.connectToNetwork(root.pendingSsid, passwordInput.text);
                                root.pendingSsid = "";
                                passwordInput.text = "";
                            }
                        }
                    }
                }
            }

            // 网络列表
            ListView {
                id: networkList

                Layout.fillWidth: true
                implicitHeight: Math.min(contentHeight, root.listMaxHeight)
                clip: true
                spacing: Config.appearance.spacing.small / 4
                interactive: contentHeight > height

                model: Network.availableNetworks

                delegate: Rectangle {
                    id: networkRow

                    required property var modelData

                    width: networkList.width
                    height: 34
                    radius: 8
                    color: netHover.hovered ? Theme.surface1 : "transparent"

                    Behavior on color {
                        ColorAnim {}
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
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
                            size: 16
                            color: networkRow.modelData.ssid === Network.networkName ? Theme.green : Theme.subtext1
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: networkRow.modelData.ssid
                            color: Theme.text
                            font.pixelSize: Config.appearance.fonts.size.small
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: networkRow.modelData.signal + "%"
                            color: Theme.overlay0
                            font.pixelSize: Config.appearance.fonts.size.tiny
                        }

                        MaterialSymbol {
                            text: networkRow.modelData.security !== "--" ? "lock" : ""
                            size: 13
                            color: Theme.overlay0
                        }

                        MaterialSymbol {
                            text: networkRow.modelData.ssid === Network.networkName ? "check_circle" : ""
                            size: 15
                            color: Theme.green
                        }
                    }

                    HoverHandler {
                        id: netHover
                    }

                    TapHandler {
                        onTapped: root.connectToWifi(networkRow.modelData.ssid, networkRow.modelData.security)
                    }
                }
            }

            // 重新扫描（外层撑满宽度，按钮居中）
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 26

                Rectangle {
                    anchors.centerIn: parent
                    width: rescanRow.implicitWidth + 20
                    height: 26
                    radius: 8
                    color: rescanArea.containsMouse ? Theme.surface2 : Theme.surface1

                    RowLayout {
                        id: rescanRow

                        anchors.centerIn: parent
                        spacing: 6

                        MaterialSymbol {
                            text: "refresh"
                            size: 13
                            color: Theme.text
                        }

                        StyledText {
                            text: qsTr("重新扫描")
                            color: Theme.text
                            font.pixelSize: Config.appearance.fonts.size.tiny
                        }
                    }

                    MouseArea {
                        id: rescanArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Network.scanNetworks()
                    }
                }
            }
        }

        // ================= 蓝牙 =================
        // ==== 开关行 ====
        Rectangle {
            id: btRow

            Layout.fillWidth: true
            implicitHeight: root.rowHeight
            radius: root.rowRadius
            color: btTap.hovered ? Theme.surface1 : "transparent"

            Behavior on color {
                ColorAnim {}
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 10

                MaterialSymbol {
                    text: Bluetooth.getIcon()
                    size: 20
                    color: Bluetooth.enabled ? Theme.blue : Theme.danger
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: Bluetooth.enabled ? qsTr("蓝牙") : qsTr("蓝牙已关闭")
                        color: Theme.text
                        font.pixelSize: Config.appearance.fonts.size.medium
                        font.bold: true

                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: {
                            if (!Bluetooth.available)
                                return qsTr("未检测到适配器");
                            if (Bluetooth.discovering)
                                return qsTr("正在搜索设备...");
                            if (Bluetooth.enabled)
                                return qsTr("%1 个已配对设备").arg(Bluetooth.pairedDevices.length);
                            return qsTr("点击开关开启");
                        }
                        color: Theme.subtext1
                        font.pixelSize: Config.appearance.fonts.size.tiny

                        Layout.fillWidth: true
                    }
                }

                MaterialSymbol {
                    text: root.btExpanded ? "keyboard_arrow_up" : "keyboard_arrow_down"
                    size: 18
                    color: Theme.overlay0

                    TapHandler {
                        onTapped: root.btExpanded = !root.btExpanded
                    }
                }

                StyledSwitch {
                    checked: Bluetooth.enabled
                    enabled: Bluetooth.available
                    onToggled: checked => Bluetooth.adapter.enabled = checked
                }
            }

            TapHandler {
                id: btTap

                onTapped: root.btExpanded = !root.btExpanded
            }
        }

        // ==== 设备列表 ====
        ColumnLayout {
            visible: root.btExpanded && Bluetooth.enabled
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small / 2

            Behavior on implicitHeight {
                NumberAnim {}
            }

            ListView {
                id: deviceList

                Layout.fillWidth: true
                implicitHeight: Math.min(contentHeight, root.listMaxHeight)
                clip: true
                spacing: Config.appearance.spacing.small / 4
                interactive: contentHeight > height

                model: ScriptModel {
                    values: Bluetooth.sortDevices([...Bluetooth.pairedDevices])
                }

                delegate: Rectangle {
                    id: deviceRow

                    required property var modelData

                    readonly property bool connected: modelData?.connected ?? false

                    width: deviceList.width
                    height: 36
                    radius: 8
                    color: devHover.hovered ? Theme.surface1 : "transparent"

                    Behavior on color {
                        ColorAnim {}
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        MaterialSymbol {
                            text: Bluetooth.getDeviceIcon(deviceRow.modelData)
                            size: 18
                            color: deviceRow.connected ? Theme.blue : Theme.subtext1
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            StyledText {
                                text: deviceRow.modelData?.name || deviceRow.modelData?.deviceName || qsTr("未知设备")
                                color: Theme.text
                                font.pixelSize: Config.appearance.fonts.size.small
                                elide: Text.ElideRight

                                Layout.fillWidth: true
                            }

                            StyledText {
                                text: deviceRow.connected ? qsTr("已连接") : Bluetooth.isDeviceBusy(deviceRow.modelData) ? qsTr("连接中...") : qsTr("未连接")
                                color: deviceRow.connected ? Theme.green : Theme.overlay0
                                font.pixelSize: Config.appearance.fonts.size.tiny
                            }
                        }

                        MaterialSymbol {
                            text: {
                                if (deviceRow.modelData?.batteryAvailable)
                                    return "battery_" + Math.max(1, Math.min(6, Math.round((deviceRow.modelData?.battery ?? 0) * 6))) + "_bar";
                                return "";
                            }
                            size: 14
                            color: Theme.overlay0
                        }

                        MaterialSymbol {
                            text: deviceRow.connected ? "check_circle" : "link"
                            size: 15
                            color: deviceRow.connected ? Theme.green : Theme.overlay0
                        }
                    }

                    HoverHandler {
                        id: devHover
                    }

                    TapHandler {
                        onTapped: {
                            if (!deviceRow.connected && !Bluetooth.isDeviceBusy(deviceRow.modelData))
                                Bluetooth.connectDeviceWithTrust(deviceRow.modelData);
                        }
                    }
                }
            }

            StyledText {
                visible: Bluetooth.pairedDevices.length === 0 && !Bluetooth.discovering
                text: qsTr("暂无已配对设备")
                color: Theme.overlay0
                font.pixelSize: Config.appearance.fonts.size.tiny

                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // WiFi 密码连接辅助
    function connectToWifi(ssid: string, security: string): void {
        if (security === "--" || security === "none") {
            Network.connectToNetwork(ssid, "");
            root.pendingSsid = "";
        } else {
            root.pendingSsid = ssid;
        }
    }
}
