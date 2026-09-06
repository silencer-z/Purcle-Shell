pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Configs
import qs.services
import qs.components

// 蓝牙弹出面板：开关 + 已配对设备列表
Item {
    id: root

    property int maxHeight: 0

    readonly property int padding: Config.appearance.padding.normal
    readonly property int rowRadius: 10

    implicitWidth: 320
    implicitHeight: Math.min(column.implicitHeight + padding * 2, root.maxHeight)

    ColumnLayout {
        id: column

        anchors.centerIn: parent
        width: parent.width - root.padding * 2
        spacing: Config.appearance.spacing.smaller

        // ==== 开关 + 状态 ====
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
                    text: Bluetooth.getIcon()
                    size: 22
                    color: Bluetooth.enabled ? Theme.blue : Theme.danger
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: Bluetooth.enabled ? "蓝牙" : "蓝牙已关闭"
                        color: Theme.text
                        font.pixelSize: 13
                        font.bold: true

                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: {
                            if (!Bluetooth.available)
                                return "未检测到适配器";
                            if (Bluetooth.discovering)
                                return "正在搜索设备...";
                            if (Bluetooth.enabled)
                                return `${Bluetooth.pairedDevices.length} 个已配对设备`;
                            return "点击右侧开关开启";
                        }
                        color: Theme.subtext1
                        font.pixelSize: 11

                        Layout.fillWidth: true
                    }
                }

                StyledSwitch {
                    checked: Bluetooth.enabled
                    enabled: Bluetooth.available
                    onToggled: checked => Bluetooth.adapter.enabled = checked
                }
            }
        }

        // ==== 设备列表 ====
        ListView {
            id: deviceList

            visible: Bluetooth.enabled
            Layout.fillWidth: true

            implicitHeight: {
                const desired = contentHeight;
                const available = root.maxHeight - 52 - Config.appearance.spacing.smaller * 2 - root.padding * 2;
                return Math.min(desired, Math.max(available, 0));
            }
            clip: true
            spacing: Config.appearance.spacing.small / 2
            interactive: contentHeight > height

            model: ScriptModel {
                values: Bluetooth.sortDevices([...Bluetooth.pairedDevices])
            }

            delegate: Rectangle {
                id: deviceRow

                required property var modelData

                readonly property bool connected: modelData?.connected ?? false

                width: deviceList.width
                height: 42
                radius: root.rowRadius
                color: hoverHandler.hovered ? Theme.surface1 : Theme.surface0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    MaterialSymbol {
                        text: Bluetooth.getDeviceIcon(deviceRow.modelData)
                        size: 20
                        color: deviceRow.connected ? Theme.blue : Theme.subtext1
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        StyledText {
                            text: deviceRow.modelData?.name || deviceRow.modelData?.deviceName || "未知设备"
                            color: Theme.text
                            font.pixelSize: 13
                            elide: Text.ElideRight

                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: deviceRow.connected ? "已连接" : Bluetooth.isDeviceBusy(deviceRow.modelData) ? "连接中..." : "未连接"
                            color: deviceRow.connected ? Theme.green : Theme.overlay0
                            font.pixelSize: 11
                        }
                    }

                    MaterialSymbol {
                        text: {
                            if (deviceRow.modelData?.batteryAvailable)
                                return "battery_" + Math.max(1, Math.min(6, Math.round((deviceRow.modelData?.battery ?? 0) * 6))) + "_bar";
                            return "";
                        }
                        size: 16
                        color: Theme.overlay0
                    }

                    MaterialSymbol {
                        text: deviceRow.connected ? "check_circle" : "link"
                        size: 16
                        color: deviceRow.connected ? Theme.green : Theme.overlay0
                    }
                }

                HoverHandler {
                    id: hoverHandler
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
            visible: Bluetooth.enabled && Bluetooth.pairedDevices.length === 0 && !Bluetooth.discovering
            text: "暂无已配对设备"
            color: Theme.overlay0
            font.pixelSize: 12

            Layout.alignment: Qt.AlignHCenter
        }
    }
}