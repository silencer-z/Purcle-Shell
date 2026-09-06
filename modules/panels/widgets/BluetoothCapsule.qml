import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services

// Aylur toggle-button 风格蓝牙胶囊：有连接设备时 primary 填充
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

    readonly property bool active: getConnectedDeviceName() !== ""

    implicitWidth: 500
    implicitHeight: 60

    // Bluetooth Popup Window
    BluetoothPopupPanel {
        id: bluetoothPopup
        targetItem: root
        visible: root.expanded
    }

    Rectangle {
        id: capsule

        anchors.fill: parent
        radius: 14
        color: root.active ? Theme.mauve : capsuleHover.hovered ? Theme.surface1 : Theme.surface0
        border.width: root.active ? 0 : 1
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

        // 蓝牙图标
        MaterialSymbol {
            text: Bluetooth.getIcon(null)
            size: 24
            color: root.active ? Theme.onPrimary : Bluetooth.enabled ? Theme.blue : Theme.danger
            Layout.preferredWidth: 30

            Behavior on color {
                ColorAnim {}
            }
        }

        // 连接信息
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                text: getConnectedDeviceName() || (Bluetooth.enabled ? "已开启" : "未连接")
                font.pixelSize: 14
                font.bold: true
                color: root.active ? Theme.onPrimary : Theme.text
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnim {}
                }
            }

            StyledText {
                text: getConnectionStatusText()
                font.pixelSize: 11
                color: root.active ? Qt.alpha(Theme.onPrimary, 0.75) : Theme.subtext1

                Behavior on color {
                    ColorAnim {}
                }
            }

        }

        // 展开/收起箭头
        MaterialSymbol {
            text: root.expanded ? "keyboard_arrow_up" : "keyboard_arrow_down"
            size: 20
            color: root.active ? Theme.onPrimary : Theme.overlay0
        }

    }

    HoverHandler {
        id: capsuleHover
    }

    TapHandler {
        // 蓝牙扫描由系统自动管理，不需要手动触发
        onTapped: root.expanded = !root.expanded
    }
}