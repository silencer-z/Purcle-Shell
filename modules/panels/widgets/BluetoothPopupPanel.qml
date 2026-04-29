import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components
import qs.services

Popup {
    id: root

    property var targetItem: null
    property int maxWidth: 400
    property int maxHeight: 400

    // 定位到目标元素下方
    parent: targetItem ? targetItem.parent : null

    x: targetItem ? targetItem.x : 0
    y: targetItem ? targetItem.y + targetItem.height : 0

    width: Math.min(maxWidth, targetItem ? Math.max(targetItem.width, 400) : 400)
    height: Math.min(maxHeight, Math.max(150, contentColumn.implicitHeight + 40))

    // Popup 样式设置
    modal: true
    dim: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // 背景和边框
    background: Rectangle {
        radius: 12
        color: "#1e1e2e"
        border.color: "#45475a"
        border.width: 1
    }

    // 内容区域 - 直接使用 ColumnLayout，不需要 ScrollView
    contentItem: ColumnLayout {
        id: contentColumn
        width: root.width - 20
        spacing: 8

        // 蓝牙开关
        Rectangle {
            Layout.fillWidth: true
            height: 45
            radius: 8
            color: "#313244"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                MaterialSymbol {
                    text: "bluetooth"
                    size: 20
                    color: Bluetooth.enabled ? "#a6e3a1" : "#f38ba8"
                }

                StyledText {
                    text: "蓝牙"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#cdd6f4"
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 20
                    radius: 10
                    color: Bluetooth.enabled ? "#89b4fa" : "#45475a"

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: "#cdd6f4"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Bluetooth.enabled ? 22 : 2

                        Behavior on anchors.leftMargin {
                            NumberAnimation { duration: 200 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (Bluetooth.adapter)
                                Bluetooth.adapter.enabled = !Bluetooth.adapter.enabled;
                        }
                    }
                }
            }
        }

        // 扫描状态指示
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: "#313244"
            visible: Bluetooth.enabled && Bluetooth.discovering

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                MaterialSymbol {
                    text: "sync"
                    size: 16
                    color: "#a6e3a1"
                }

                StyledText {
                    text: "正在搜索设备..."
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    color: "#cdd6f4"
                }
            }
        }

        // 设备列表标题
        StyledText {
            text: "可用设备"
            font.pixelSize: 13
            font.bold: true
            color: "#cdd6f4"
            visible: Bluetooth.enabled && (Bluetooth.pairedDevices.length > 0 || (Bluetooth.devices && Bluetooth.devices.values.length > 0))
        }

        // 设备列表
        ListView {
            id: deviceList

            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(250, contentHeight)
            model: getAllDevices()
            spacing: 8
            visible: model.count > 0
            clip: true

            delegate: Rectangle {
                width: ListView.view.width
                height: 55
                radius: 8
                color: modelData.connected ? "#45475a" : "#313244"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    MaterialSymbol {
                        text: Bluetooth.getDeviceIcon(modelData)
                        size: 20
                        color: modelData.connected ? "#a6e3a1" : "#a6adc8"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: modelData.name || modelData.deviceName || "未知设备"
                            font.pixelSize: 13
                            font.bold: modelData.connected
                            color: "#cdd6f4"
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: getDeviceStatusText(modelData)
                            font.pixelSize: 11
                            color: "#a6adc8"
                        }
                    }

                    StyledText {
                        text: modelData.connected ? "已连接" : modelData.paired ? "已配对" : "连接"
                        font.pixelSize: 12
                        color: modelData.connected ? "#a6e3a1" : "#89b4fa"
                        visible: !connectBtn.visible
                    }

                    Rectangle {
                        id: connectBtn

                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 25
                        radius: 12
                        color: "#89b4fa"
                        visible: !modelData.connected && !modelData.paired

                        StyledText {
                            anchors.centerIn: parent
                            text: "连接"
                            font.pixelSize: 11
                            color: "#cdd6f4"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !Bluetooth.isDeviceBusy(modelData)
                            onEntered: { parent.color = "#74c7ec"; }
                            onExited: { parent.color = "#89b4fa"; }
                            onClicked: {
                                if (modelData && Bluetooth.canConnect(modelData))
                                    Bluetooth.connectDeviceWithTrust(modelData);
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !Bluetooth.isDeviceBusy(modelData)
                    onEntered: {
                        parent.color = modelData.connected ? "#585b70" : "#45475a";
                    }
                    onExited: {
                        parent.color = modelData.connected ? "#45475a" : "#313244";
                    }
                    onClicked: {
                        if (modelData) {
                            if (modelData.connected)
                                modelData.disconnect();
                            else if (modelData.paired)
                                modelData.connect();
                            else if (Bluetooth.canConnect(modelData))
                                Bluetooth.connectDeviceWithTrust(modelData);
                        }
                    }
                }
            }
        }

        // 无设备提示
        StyledText {
            text: "未找到设备"
            font.pixelSize: 13
            color: "#a6adc8"
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            verticalAlignment: Text.AlignVCenter
            visible: Bluetooth.enabled && getAllDevices().length === 0 && !Bluetooth.discovering
        }
    }

    // 辅助函数
    function getDeviceStatusText(device) {
        if (!device)
            return "未知";

        if (device.connected)
            return "已连接";

        if (device.paired)
            return "已配对";

        if (device.pairing)
            return "正在配对...";

        if (device.state === 1)
            return "正在连接...";

        if (device.state === 2)
            return "正在断开...";

        return Bluetooth.getSignalStrength(device);
    }

    function getAllDevices() {
        if (!Bluetooth.devices)
            return [];

        const allDevices = [];
        for (let device of Bluetooth.pairedDevices) {
            if (device)
                allDevices.push(device);
        }
        for (let device of Bluetooth.devices.values) {
            if (device && !device.paired)
                allDevices.push(device);
        }
        return Bluetooth.sortDevices(allDevices);
    }
}
