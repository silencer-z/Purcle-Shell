import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components
import qs.services

Popup {
    id: root

    property var targetItem: null
    property int maxWidth: 400
    property int maxHeight: 300

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

    // 设置内容边距，避免内容被裁剪
    padding: 10

    // Popup 打开时自动扫描网络
    onOpened: {
        if (!Network.isScanning) {
            Network.scanNetworks();
        }
    }

    // 背景和边框
    background: Rectangle {
        radius: 12
        color: Theme.base
        border.color: Theme.surface1
        border.width: 1
    }

    // 内容区域 - 直接使用 ColumnLayout，不需要 ScrollView
    contentItem: ColumnLayout {
        id: contentColumn
        width: parent.width
        height:parent.height
        spacing: 8

        // 扫描状态指示器
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: Theme.surface0
            visible: Network.isScanning

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                MaterialSymbol {
                    text: "wifi_find"
                    size: 18
                    color: Theme.green
                }

                StyledText {
                    text: "正在扫描网络..."
                    font.pixelSize: 13
                    color: Theme.text
                }
            }
        }

        // 扫描按钮（非扫描状态时显示）
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: Theme.surface0
            visible: !Network.isScanning

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                MaterialSymbol {
                    text: "refresh"
                    size: 18
                    color: Theme.green
                }

                StyledText {
                    text: `刷新网络列表 (${Network.availableNetworksCount})`
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    color: Theme.text
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: { parent.color = Theme.surface1; }
                onExited: { parent.color = Theme.surface0; }
                onClicked: {
                    console.log("Manual scan triggered");
                    Network.scanNetworks();
                }
            }
        }

        // 设备列表标题
        StyledText {
            text: "可用网络"
            font.pixelSize: 13
            font.bold: true
            color: Theme.text
            visible: !Network.isScanning && Network.availableNetworksCount > 0
        }

        // 网络列表
        ListView {
            id: availableNetworksList

            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(250, contentHeight)
            model: Network.availableNetworks
            spacing: 8
            visible: Network.availableNetworksCount > 0 && !Network.isScanning
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 55
                radius: 8
                color: Network.networkName === model.ssid ? Theme.surface1 : Theme.surface0
                visible: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    MaterialSymbol {
                        text: model.signal > 80 ? "signal_wifi_4_bar" :
                              model.signal > 60 ? "network_wifi_3_bar" :
                              model.signal > 30 ? "network_wifi_2_bar" :
                              model.signal > 15 ? "network_wifi_1_bar" : "signal_wifi_0_bar"
                        size: 20
                        color: Theme.green
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: model.ssid || "未知网络"
                            font.pixelSize: 13
                            font.bold: Network.networkName === model.ssid
                            color: Theme.text
                            elide: Text.ElideRight
                        }

                        RowLayout {
                            spacing: 6

                            StyledText {
                                text: `${model.signal}%`
                                font.pixelSize: 11
                                color: Theme.subtext1
                            }

                            MaterialSymbol {
                                text: model.security && model.security !== "--" ? "lock" : "lock_open"
                                size: 12
                                color: Theme.yellow
                                visible: model.security && model.security !== "--"
                            }
                        }
                    }

                    // 连接状态或按钮
                    StyledText {
                        text: Network.networkName === model.ssid ? "已连接" : "连接"
                        font.pixelSize: 12
                        color: Network.networkName === model.ssid ? Theme.green : Theme.blue
                    }

                    Rectangle {
                        id: connectBtn

                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 25
                        radius: 12
                        color: Theme.blue
                        visible: Network.networkName !== model.ssid

                        StyledText {
                            anchors.centerIn: parent
                            text: "连接"
                            font.pixelSize: 11
                            color: Theme.text
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: { parent.color = Theme.sky; }
                            onExited: { parent.color = Theme.blue; }
                            onClicked: {
                                if (model.security && model.security !== "--") {
                                    // 加密网络 - 显示密码输入对话框
                                    pendingSsid = model.ssid || "";
                                    passwordDialog.visible = true;
                                    passwordInput.text = "";
                                    passwordInput.focus = true;
                                } else {
                                    // 开放网络
                                    Network.connectToNetwork(model.ssid || "", "");
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: disconnectBtn

                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 25
                        radius: 12
                        color: Theme.danger
                        visible: Network.networkName === model.ssid

                        StyledText {
                            anchors.centerIn: parent
                            text: "断开"
                            font.pixelSize: 11
                            color: Theme.text
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: { parent.color = Qt.lighter(Theme.danger, 1.1); }
                            onExited: { parent.color = Theme.danger; }
                            onClicked: { Network.disconnectNetwork(); }
                        }
                    }

                    // 外层 MouseArea - 处理整个条目的悬停和点击
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        propagateComposedEvents: true

                        onEntered: {
                            parent.color = Network.networkName === model.ssid ? Theme.surface2 : Theme.surface1;
                        }

                        onExited: {
                            parent.color = Network.networkName === model.ssid ? Theme.surface1 : Theme.surface0;
                        }

                        // 点击时触发连接/断开（如果没有点击到按钮）
                        onClicked: (mouse) => {
                            // 只有点击在按钮之外的区域才触发
                            const mousePos = mapToItem(parent, mouse.x, mouse.y);
                            const inConnectBtn = connectBtn.contains(mousePos);
                            const inDisconnectBtn = disconnectBtn.contains(mousePos);

                            if (!inConnectBtn && !inDisconnectBtn) {
                                if (Network.networkName === model.ssid) {
                                    Network.disconnectNetwork();
                                } else {
                                    if (model.security && model.security !== "--") {
                                        pendingSsid = model.ssid || "";
                                        passwordDialog.visible = true;
                                        passwordInput.text = "";
                                        passwordInput.focus = true;
                                    } else {
                                        Network.connectToNetwork(model.ssid || "", "");
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // 无网络提示
        StyledText {
            text: "未找到可用网络"
            font.pixelSize: 13
            color: Theme.subtext1
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            verticalAlignment: Text.AlignVCenter
            visible: !Network.isScanning && Network.availableNetworksCount === 0
        }
    }

    // 待连接的网络 SSID
    property string pendingSsid: ""

    // 密码输入对话框
    Dialog {
        id: passwordDialog
        width: 320
        height: 200

        background: Rectangle {
            color: Theme.base
            radius: 16
            border.color: Theme.surface1
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            StyledText {
                text: "输入 WiFi 密码"
                font.pixelSize: 16
                font.bold: true
                color: Theme.text
            }

            StyledText {
                text: pendingSsid
                font.pixelSize: 13
                color: Theme.subtext1
                elide: Text.ElideRight
            }

            TextField {
                id: passwordInput
                Layout.fillWidth: true
                height: 40
                placeholderText: "请输入密码"
                echoMode: TextInput.Password
                selectByMouse: true
                font.pixelSize: 14
                color: Theme.text
                background: Rectangle {
                    color: Theme.surface0
                    radius: 8
                    border.color: passwordInput.activeFocus ? Theme.blue : Theme.surface1
                    border.width: 1
                }

                Keys.onReturnPressed: {
                    if (text.length > 0) {
                        Network.connectToNetwork(pendingSsid, text);
                        passwordDialog.visible = false;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    background: Rectangle {
                        color: parent.hovered ? Theme.surface2 : Theme.surface1
                        radius: 8
                    }

                    contentItem: StyledText {
                        text: "取消"
                        font.pixelSize: 13
                        color: Theme.text
                        anchors.centerIn: parent
                    }

                    onClicked: { passwordDialog.visible = false; }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    background: Rectangle {
                        color: parent.hovered ? Theme.sky : Theme.blue
                        radius: 8
                    }

                    contentItem: StyledText {
                        text: "连接"
                        font.pixelSize: 13
                        color: Theme.text
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        if (passwordInput.text.length > 0) {
                            Network.connectToNetwork(pendingSsid, passwordInput.text);
                            passwordDialog.visible = false;
                        }
                    }
                }
            }
        }
    }

    // 密码错误 / 需要密钥时重新弹窗
    Connections {
        target: Network

        function onConnectFailed(ssid: string) {
            if (ssid && ssid === root.pendingSsid && passwordDialog) {
                passwordDialog.visible = true;
                passwordInput.text = "";
                passwordInput.focus = true;
            }
        }
    }
}
