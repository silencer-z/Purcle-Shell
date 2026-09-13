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

    ColumnLayout {
        anchors.fill: parent
        spacing: Config.appearance.spacing.normal

        // ==== 标题栏 ====
        RowLayout {
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small

            MaterialSymbol {
                text: "notifications"
                size: 20
                color: Notifications.historyCount > 0 ? Theme.mauve : Theme.overlay0

                Behavior on color {
                    ColorAnim {}
                }
            }

            StyledText {
                text: qsTr("通知")
                color: Theme.text
                font.pixelSize: 15
                font.bold: true
            }

            StyledText {
                visible: Notifications.historyCount > 0
                text: Notifications.historyCount
                color: Theme.overlay0
                font.pixelSize: 12
            }

            Item {
                Layout.fillWidth: true
            }

            // DND 开关
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                radius: 15
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

            // 清空
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                radius: 15
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

        // ==== 空状态 ====
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
                font.pixelSize: 13
            }

            Item {
                Layout.fillHeight: true
            }
        }

        // ==== 历史列表 ====
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

            delegate: Rectangle {
                id: historyCard

                required property var wrapper

                readonly property var n: wrapper

                width: historyList.width
                implicitHeight: cardContent.implicitHeight + Config.appearance.padding.larger * 2
                radius: Config.appearance.rounding.small
                color: cardHover.hovered ? Theme.surface0 : "transparent"
                border.width: cardHover.hovered ? 1 : 0
                border.color: Theme.surface0

                Behavior on color {
                    ColorAnim {}
                }

                RowLayout {
                    id: cardContent

                    anchors.fill: parent
                    anchors.margins: Config.appearance.padding.larger
                    spacing: Config.appearance.spacing.small

                    // 应用图标
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 9
                        color: Theme.surface0

                        AppIcon {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: historyCard.n.icon
                        }
                    }

                    // 文本主体
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Config.appearance.spacing.small

                            StyledText {
                                Layout.fillWidth: true
                                text: historyCard.n.summary !== "" ? historyCard.n.summary : historyCard.n.appName
                                color: Theme.text
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: historyCard.n.timeStr
                                color: Theme.overlay0
                                font.pixelSize: 11
                            }
                        }

                        StyledText {
                            visible: historyCard.n.body !== ""
                            Layout.fillWidth: true
                            text: historyCard.n.body
                            color: Theme.subtext1
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                        }

                        // 操作按钮
                        RowLayout {
                            visible: historyCard.n.actions.length > 0
                            Layout.fillWidth: true
                            spacing: Config.appearance.spacing.small / 2

                            Repeater {
                                model: historyCard.n.actions

                                delegate: Rectangle {
                                    id: histActionButton

                                    required property var modelData

                                    Layout.preferredHeight: 24
                                    Layout.preferredWidth: histActionLabel.implicitWidth + 18
                                    radius: 7
                                    color: histActionHover.hovered ? Theme.surface1 : Theme.surface0

                                    Behavior on color {
                                        ColorAnim {}
                                    }

                                    StyledText {
                                        id: histActionLabel

                                        anchors.centerIn: parent
                                        text: histActionButton.modelData.label
                                        color: Theme.blue
                                        font.pixelSize: 11
                                    }

                                    HoverHandler {
                                        id: histActionHover
                                    }

                                    TapHandler {
                                        onTapped: historyCard.n.invoke(histActionButton.modelData.id)
                                    }
                                }
                            }
                        }
                    }

                    // 移除按钮（悬停显示）
                    Rectangle {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        radius: 11
                        visible: cardHover.hovered
                        color: removeBtnTap.containsMouse ? Theme.surface2 : Theme.surface1

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "close"
                            size: 14
                            color: Theme.subtext1
                        }

                        TapHandler {
                            id: removeBtnTap

                            onTapped: Notifications.remove(historyCard.n)
                        }
                    }
                }

                HoverHandler {
                    id: cardHover
                }
            }
        }
    }
}
