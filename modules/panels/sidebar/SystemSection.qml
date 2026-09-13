pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Configs
import qs.components
import qs.services

// 系统区：用户信息 + 电源模式
PanelWidget {
    id: root

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

    color: Theme.surface0

    Behavior on color {
        ColorAnim {}
    }

    implicitHeight: row.implicitHeight + Config.appearance.padding.normal * 2

    RowLayout {
        id: row

        anchors.fill: parent
        spacing: Config.appearance.spacing.normal

        // ==== 用户信息 ====
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: Theme.mauve

            MaterialSymbol {
                anchors.centerIn: parent
                text: "person"
                size: 22
                color: Theme.onPrimary
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            StyledText {
                text: SysInfo.userName || qsTr("User")
                color: Theme.text
                font.pixelSize: Config.appearance.fonts.size.normal
                font.bold: true
                elide: Text.ElideRight

                Layout.fillWidth: true
            }

            StyledText {
                text: `${SysInfo.hostName || qsTr("未知主机")} · ${qsTr("开机")} ${SysInfo.uptime || "—"}`
                color: Theme.subtext1
                font.pixelSize: Config.appearance.fonts.size.tiny
                elide: Text.ElideRight

                Layout.fillWidth: true
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // ==== 电源模式 ====
        RowLayout {
            visible: PowerProfile.available
            spacing: Config.appearance.spacing.small / 2

            Repeater {
                model: root.powerProfiles

                delegate: Rectangle {
                    id: profileButton

                    required property var modelData

                    readonly property bool active: PowerProfile.current === profileButton.modelData.profile

                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: Config.appearance.rounding.small
                    color: profileButton.active ? profileButton.modelData.color : profileHover.hovered ? Theme.surface1 : "transparent"

                    Behavior on color {
                        ColorAnim {}
                    }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: profileButton.modelData.icon
                        size: 18
                        color: profileButton.active ? Theme.onPrimary : Theme.subtext1
                    }

                    HoverHandler {
                        id: profileHover
                    }

                    TapHandler {
                        onTapped: PowerProfile.set(profileButton.modelData.profile)
                    }

                    StyledTooltip {
                        content: profileButton.modelData.label + (profileButton.active ? qsTr("（当前）") : "")
                        alternativeVisibleCondition: profileHover.hovered
                    }
                }
            }
        }
    }
}
