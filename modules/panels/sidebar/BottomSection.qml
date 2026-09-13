pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Configs
import qs.components
import qs.services

// 底部区：电量 + 会话操作
PanelWidget {
    id: root

    readonly property color levelColor: Battery.isCritical ? Theme.danger : Battery.isLow ? Theme.warning : Battery.isCharging ? Theme.green : Theme.mauve

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

    implicitHeight: row.implicitHeight + Config.appearance.padding.normal * 2

    color: "transparent"

    RowLayout {
        id: row

        anchors.fill: parent
        spacing: Config.appearance.spacing.small

        // ==== 电量 ====
        Rectangle {
            visible: Battery.available
            Layout.preferredWidth: 150
            Layout.fillHeight: true
            radius: root.radius
            color: Theme.surface0

            Behavior on color {
                ColorAnim {}
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                MaterialSymbol {
                    text: Battery.iconName()
                    size: 20
                    color: root.levelColor

                    Behavior on color {
                        ColorAnim {}
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        text: Math.round(Battery.percentage * 100) + "%"
                        color: Theme.text
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 4
                        radius: 2
                        color: Theme.surface1

                        Rectangle {
                            id: fill

                            width: parent.width * Battery.percentage
                            height: parent.height
                            radius: 2
                            color: root.levelColor

                            Behavior on width {
                                NumberAnim {}
                            }

                            Behavior on color {
                                ColorAnim {}
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // ==== 会话操作 ====
        RowLayout {
            spacing: Config.appearance.spacing.small / 2

            Repeater {
                model: root.sessionActions

                delegate: Rectangle {
                    id: sessionButton

                    required property var modelData

                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: 10
                    color: sessionHover.hovered ? sessionButton.modelData.color : Theme.surface0

                    Behavior on color {
                        ColorAnim {}
                    }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: sessionButton.modelData.icon
                        size: 18
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

    // 会话命令
    Process {
        id: sessionProcess

        command: []
        onExited: Visibilities.sidebar = false
    }
}