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
        console.log("WiFi Popup opened");
        console.log("Popup width:", width);
        console.log("Popup height:", height);
        console.log("Popup visible:", visible);
        console.log("Network.isScanning:", Network.isScanning);
        console.log("Available networks count:", Network.availableNetworksCount);

        if (!Network.isScanning) {
            console.log("Triggering network scan...");
            Network.scanNetworks();
        } else {
            console.log("Already scanning, skipping...");
        }
    }

    // 监听扫描状态变化
    Connections {
        target: Network
        function onIsScanningChanged() {
            console.log("Scan status changed:", Network.isScanning);
        }
        function onAvailableNetworksCountChanged() {
            console.log("Available networks changed, count:", Network.availableNetworksCount);
        }
    }

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
        width: parent.width
        spacing: 8

        // 扫描状态指示器
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: "#313244"
            visible: Network.isScanning

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                IconText {
                    text: "wifi_find"
                    size: 18
                    color: "#a6e3a1"
                }

                StyledText {
                    text: "正在扫描网络..."
                    font.pixelSize: 13
                    color: "#cdd6f4"
                }
            }
        }

        // 扫描按钮（非扫描状态时显示）
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: "#313244"
            visible: !Network.isScanning

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                IconText {
                    text: "refresh"
                    size: 18
                    color: "#a6e3a1"
                }

                StyledText {
                    text: `刷新网络列表 (${Network.availableNetworksCount})`
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    color: "#cdd6f4"
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: { parent.color = "#45475a"; }
                onExited: { parent.color = "#313244"; }
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
            color: "#cdd6f4"
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

            // 调试信息
            Component.onCompleted: {
                console.log("ListView loaded");
                console.log("  model:", model);
                console.log("  count:", model.count);
                console.log("  visible:", visible);
                console.log("  Network.isScanning:", Network.isScanning);
                console.log("  Network.availableNetworksCount:", Network.availableNetworksCount);
                console.log("  ListView width:", width);
            }

            Connections {
                target: Network
                function onAvailableNetworksCountChanged() {
                    console.log("Network count changed to:", Network.availableNetworksCount);
                    console.log("  ListView count:", model.count);
                    console.log("  ListView visible:", visible);
                    console.log("  Popup width:", root.width);
                    console.log("  Popup height:", root.height);
                    console.log("  contentColumn.implicitHeight:", contentColumn.implicitHeight);
                }
            }

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 55
                radius: 8
                color: Network.networkName === model.ssid ? "#45475a" : "#313244"
                visible: true

                // 调试信息
                Component.onCompleted: {
                    console.log("Delegate created:");
                    console.log("  model:", model);
                    console.log("  model.ssid:", model.ssid);
                    console.log("  model.signal:", model.signal);
                    console.log("  index:", index);
                    console.log("  visible:", visible);
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    IconText {
                        text: model.signal > 80 ? "signal_wifi_4_bar" :
                              model.signal > 60 ? "network_wifi_3_bar" :
                              model.signal > 30 ? "network_wifi_2_bar" :
                              model.signal > 15 ? "network_wifi_1_bar" : "signal_wifi_0_bar"
                        size: 20
                        color: "#a6e3a1"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: model.ssid || "未知网络"
                            font.pixelSize: 13
                            font.bold: Network.networkName === model.ssid
                            color: "#cdd6f4"
                            elide: Text.ElideRight
                        }

                        RowLayout {
                            spacing: 6

                            StyledText {
                                text: `${model.signal}%`
                                font.pixelSize: 11
                                color: "#a6adc8"
                            }

                            IconText {
                                text: model.security && model.security !== "--" ? "lock" : "lock_open"
                                size: 12
                                color: "#f9e2af"
                                visible: model.security && model.security !== "--"
                            }
                        }
                    }

                    // 连接状态或按钮
                    StyledText {
                        text: Network.networkName === model.ssid ? "已连接" : "连接"
                        font.pixelSize: 12
                        color: Network.networkName === model.ssid ? "#a6e3a1" : "#89b4fa"
                    }

                    Rectangle {
                        id: connectBtn

                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 25
                        radius: 12
                        color: "#89b4fa"
                        visible: Network.networkName !== model.ssid

                        StyledText {
                            anchors.centerIn: parent
                            text: "连接"
                            font.pixelSize: 11
                            color: "#cdd6f4"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: { parent.color = "#74c7ec"; }
                            onExited: { parent.color = "#89b4fa"; }
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
                        color: "#f38ba8"
                        visible: Network.networkName === model.ssid

                        StyledText {
                            anchors.centerIn: parent
                            text: "断开"
                            font.pixelSize: 11
                            color: "#cdd6f4"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: { parent.color = "#eba0ac"; }
                            onExited: { parent.color = "#f38ba8"; }
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
                            parent.color = Network.networkName === model.ssid ? "#585b70" : "#45475a";
                        }

                        onExited: {
                            parent.color = Network.networkName === model.ssid ? "#45475a" : "#313244";
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
            color: "#a6adc8"
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            verticalAlignment: Text.AlignVCenter
            visible: !Network.isScanning && Network.availableNetworksCount === 0
        }

        // 调试信息 - 显示模型状态
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: "#45475a"

            StyledText {
                anchors.centerIn: parent
                text: `调试: 模型数量=${Network.availableNetworksCount}, 扫描状态=${Network.isScanning}, ListView可见=${availableNetworksList.visible}`
                font.pixelSize: 11
                color: "#a6adc8"
            }
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
            color: "#1e1e2e"
            radius: 16
            border.color: "#45475a"
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
                color: "#cdd6f4"
            }

            StyledText {
                text: pendingSsid
                font.pixelSize: 13
                color: "#a6adc8"
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
                color: "#cdd6f4"
                background: Rectangle {
                    color: "#313244"
                    radius: 8
                    border.color: passwordInput.activeFocus ? "#89b4fa" : "#45475a"
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
                        color: parent.hovered ? "#585b70" : "#45475a"
                        radius: 8
                    }

                    contentItem: StyledText {
                        text: "取消"
                        font.pixelSize: 13
                        color: "#cdd6f4"
                        anchors.centerIn: parent
                    }

                    onClicked: { passwordDialog.visible = false; }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    background: Rectangle {
                        color: parent.hovered ? "#74c7ec" : "#89b4fa"
                        radius: 8
                    }

                    contentItem: StyledText {
                        text: "连接"
                        font.pixelSize: 13
                        color: "#cdd6f4"
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
}
