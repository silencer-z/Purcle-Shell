pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Configs
import qs.components
import qs.services

// dashboard 底栏：用户信息 | 电源模式 | 会话操作
PanelWidget {
    id: root

    property string currentPowerProfile: "balanced"

    readonly property var powerProfiles: [{
        "icon": "eco",
        "label": qsTr("省电"),
        "profile": "power-saver",
        "color": Theme.green
    }, {
        "icon": "balance",
        "label": qsTr("均衡"),
        "profile": "balanced",
        "color": Theme.blue
    }, {
        "icon": "speed",
        "label": qsTr("性能"),
        "profile": "performance",
        "color": Theme.peach
    }]

    readonly property var sessionActions: [{
        "icon": "logout",
        "label": qsTr("注销"),
        "color": Theme.peach,
        "command": "hyprctl dispatch exit"
    }, {
        "icon": "restart_alt",
        "label": qsTr("重启"),
        "color": Theme.green,
        "command": "systemctl reboot"
    }, {
        "icon": "power_settings_new",
        "label": qsTr("关机"),
        "color": Theme.danger,
        "command": "systemctl poweroff"
    }]

    function executeSessionCommand(command: string): void {
        sessionProcess.command = ["sh", "-c", command];
        sessionProcess.running = true;
    }

    Component.onCompleted: {
        SysInfo.loadUserInfo();
        getPowerProfile.running = true;
    }

    RowLayout {
        anchors.fill: parent
        spacing: Config.appearance.spacing.normal

        // ==== 用户信息 ====
        RowLayout {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            spacing: Config.appearance.spacing.small

            Rectangle {
                Layout.preferredWidth: 46
                Layout.preferredHeight: 46
                Layout.leftMargin: 4
                radius: 23
                color: Theme.mauve

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "person"
                    size: 24
                    color: Theme.onPrimary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                StyledText {
                    text: SysInfo.userName || qsTr("User")
                    font.pixelSize: 18
                    font.bold: true
                    color: Theme.text
                    elide: Text.ElideRight

                    Layout.fillWidth: true
                }

                StyledText {
                    text: `${SysInfo.hostName || ""} · ${qsTr("开机")} ${SysInfo.uptime || qsTr("未知")}`
                    font.pixelSize: 11
                    color: Theme.subtext1
                    elide: Text.ElideRight

                    Layout.fillWidth: true
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // ==== 电源模式 ====
        RowLayout {
            spacing: Config.appearance.spacing.small / 2

            Repeater {
                model: root.powerProfiles

                delegate: Rectangle {
                    id: profileButton

                    required property var modelData

                    readonly property bool active: root.currentPowerProfile === profileButton.modelData.profile

                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    radius: Config.appearance.rounding.small
                    color: profileButton.active ? profileButton.modelData.color : profileHover.hovered ? Theme.surface1 : Theme.surface0

                    Behavior on color {
                        ColorAnim {}
                    }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: profileButton.modelData.icon
                        size: 20
                        color: profileButton.active ? Theme.onPrimary : Theme.subtext1
                    }

                    HoverHandler {
                        id: profileHover
                    }

                    TapHandler {
                        onTapped: {
                            setPowerProfile.command = ["powerprofilesctl", "set", profileButton.modelData.profile];
                            setPowerProfile.running = true;
                        }
                    }

                    StyledTooltip {
                        content: profileButton.modelData.label + (profileButton.active ? qsTr("（当前）") : "")
                        alternativeVisibleCondition: profileHover.hovered
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 14
            Layout.bottomMargin: 14
            color: Theme.surface1
        }

        // ==== 会话操作 ====
        RowLayout {
            spacing: Config.appearance.spacing.small / 2

            Repeater {
                model: root.sessionActions

                delegate: Rectangle {
                    id: sessionButton

                    required property var modelData

                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    radius: Config.appearance.rounding.small
                    color: sessionHover.hovered ? sessionButton.modelData.color : Theme.surface0

                    Behavior on color {
                        ColorAnim {}
                    }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: sessionButton.modelData.icon
                        size: 20
                        color: sessionHover.hovered ? Theme.onPrimary : Theme.subtext1
                    }

                    HoverHandler {
                        id: sessionHover
                    }

                    TapHandler {
                        onTapped: root.executeSessionCommand(sessionButton.modelData.command)
                    }

                    StyledTooltip {
                        content: sessionButton.modelData.label
                        alternativeVisibleCondition: sessionHover.hovered
                    }
                }
            }
        }
    }

    // 读取当前电源模式
    Process {
        id: getPowerProfile

        command: ["powerprofilesctl", "get"]

        stdout: StdioCollector {
            onStreamFinished: root.currentPowerProfile = text.trim()
        }
    }

    // 切换电源模式
    Process {
        id: setPowerProfile

        command: []
        onExited: getPowerProfile.running = true
    }

    // 会话命令
    Process {
        id: sessionProcess

        command: []
        onExited: Visibilities.dashboard = false
    }
}
