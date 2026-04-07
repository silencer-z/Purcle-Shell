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

    // 辅助函数
    function getConnectedDeviceName() {
        if (!Bluetooth.devices)
            return "";

        for (let device of Bluetooth.devices.values) {
            if (device && device.connected)
                return device.name || device.deviceName;
        }
        return "";
    }

    function getConnectionStatusText() {
        if (!Bluetooth.available)
            return "蓝牙不可用";

        if (!Bluetooth.enabled)
            return "蓝牙已关闭";

        if (Bluetooth.discovering)
            return "正在搜索设备...";

        const connectedDevice = getConnectedDeviceName();
        if (connectedDevice)
            return `已连接至 ${connectedDevice}`;

        const pairedCount = Bluetooth.pairedDevices.length;
        if (pairedCount > 0)
            return `${pairedCount} 个已配对设备`;

        return "蓝牙已开启";
    }

    implicitWidth: 500
    implicitHeight: 60

    // Bluetooth Popup Window
    BluetoothPopupPanel {
        id: bluetoothPopup
        targetItem: root
        visible: root.expanded
    }

    // 胶囊背景
    Rectangle {
        id: capsule
        anchors.fill: parent
        radius: 20
        color: "#313244"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 12

        // 蓝牙图标
        IconText {
            text: Bluetooth.getIcon(null)
            size: 24
            color: Bluetooth.enabled ? "#a6e3a1" : "#f38ba8"
            Layout.preferredWidth: 30
        }

        // 连接信息
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                text: getConnectedDeviceName() || (Bluetooth.enabled ? "已开启" : "未连接")
                font.pixelSize: 14
                font.bold: true
                color: "#cdd6f4"
                elide: Text.ElideRight
            }

            StyledText {
                text: getConnectionStatusText()
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
                    // 蓝牙扫描由系统自动管理，不需要手动触发
                }
            }

        }

    }
}
