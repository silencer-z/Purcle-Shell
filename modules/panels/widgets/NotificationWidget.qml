pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Configs
import qs.components
import qs.services

// 通知中心：历史列表 + DND + 清空
PanelWidget {
    id: root

    implicitHeight: 400
    color: Theme.surface0

    Behavior on color {
        ColorAnim {}
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Config.appearance.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small

            MaterialSymbol {
                text: "notifications"
                size: Config.appearance.fonts.size.large
                color: Notifications.historyCount > 0 ? Theme.mauve : Theme.overlay0

                Behavior on color {
                    ColorAnim {}
                }
            }

            StyledText {
                text: qsTr("通知")
                color: Theme.text
                font.pixelSize: Config.appearance.fonts.size.large
                font.bold: true
            }

            StyledText {
                visible: Notifications.historyCount > 0
                text: Notifications.historyCount
                color: Theme.overlay0
                font.pixelSize: Config.appearance.fonts.size.small
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredWidth: Config.appearance.sizes.icon
                Layout.preferredHeight: Config.appearance.sizes.icon
                radius: Config.appearance.sizes.iconRadius
                color: dndArea.containsMouse ? (Notifications.doNotDisturb ? Qt.alpha(Theme.danger, 0.8) : Theme.surface1) : (Notifications.doNotDisturb ? Theme.danger : Theme.surface1)

                Behavior on color {
                    ColorAnim {}
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: Notifications.doNotDisturb ? "do_not_disturb_on" : "do_not_disturb_off"
                    size: 18
                    color: Notifications.doNotDisturb ? Theme.onPrimary : Theme.subtext1
                }

                MouseArea {
                    id: dndArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifications.doNotDisturb = !Notifications.doNotDisturb
                }

                StyledTooltip {
                    content: Notifications.doNotDisturb ? qsTr("勿扰模式开启中，点击关闭") : qsTr("开启勿扰模式")
                    alternativeVisibleCondition: dndArea.containsMouse
                }
            }

            Rectangle {
                Layout.preferredWidth: Config.appearance.sizes.icon
                Layout.preferredHeight: Config.appearance.sizes.icon
                radius: Config.appearance.sizes.iconRadius
                color: clearArea.containsMouse ? (Notifications.historyCount > 0 ? Qt.alpha(Theme.danger, 0.8) : Theme.surface1) : Theme.surface1
                enabled: Notifications.historyCount > 0
                opacity: enabled ? 1 : 0.5

                Behavior on color {
                    ColorAnim {}
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "clear_all"
                    size: 18
                    color: Notifications.historyCount > 0 ? Theme.danger : Theme.subtext1
                }

                MouseArea {
                    id: clearArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifications.clearAll()
                }

                StyledTooltip {
                    content: qsTr("清空全部通知")
                    alternativeVisibleCondition: clearArea.containsMouse
                }
            }
        }

        ColumnLayout {
            visible: Notifications.historyCount === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Config.appearance.spacing.small

            Item {
                Layout.fillHeight: true
            }

            MaterialSymbol {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Notifications.doNotDisturb ? "do_not_disturb_on" : "notifications_off"
                size: 44
                color: Theme.surface2
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Notifications.doNotDisturb ? qsTr("勿扰模式开启中") : qsTr("暂无通知")
                color: Theme.overlay0
                font.pixelSize: Config.appearance.fonts.size.medium
            }

            Item {
                Layout.fillHeight: true
            }
        }

        ListView {
            id: historyList

            visible: Notifications.historyCount > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Config.appearance.spacing.small
            clip: true
            interactive: contentHeight > height

            model: Notifications.historyModel

            add: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Config.appearance.animations.durations.small
                }
            }

            remove: Transition {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: Config.appearance.animations.durations.small
                }
            }

            displaced: Transition {
                NumberAnimation {
                    property: "y"
                    duration: Config.appearance.animations.durations.small
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Config.appearance.animations.curves.standard
                }
            }

            delegate: NotificationCard {
                required property var wrapper

                width: historyList.width
                notification: wrapper
                onDismissed: Notifications.remove(wrapper)
                onActionInvoked: (actionId) => wrapper.invoke(actionId)
            }
        }
    }
}
