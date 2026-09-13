pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Configs
import qs.components
import qs.services

// 通知卡片：popup 与历史列表共用。
// popupMode=true：urgency 色条、整卡点击关闭、附图、正文 2 行
// popupMode=false：hover 边框、仅关闭按钮移除、正文 4 行
Rectangle {
    id: root

    required property var notification
    property bool popupMode: false

    signal dismissed()
    signal actionInvoked(string actionId)

    readonly property var n: notification
    readonly property int cardPadding: root.popupMode ? Config.appearance.padding.normal : Config.appearance.padding.larger
    readonly property int bodyMaxLines: root.popupMode ? 2 : 4

    readonly property color restingColor: root.popupMode ? Theme.surface0 : "transparent"
    readonly property color hoverColor: root.popupMode ? Theme.surface1 : Theme.surface0

    radius: Config.appearance.rounding.small
    color: cardHover.hovered ? root.hoverColor : root.restingColor
    border.width: 0

    implicitWidth: cardRow.implicitWidth + root.cardPadding * 2
    implicitHeight: cardRow.implicitHeight + root.cardPadding * 2

    Behavior on color {
        ColorAnim {}
    }

    RowLayout {
        id: cardRow

        anchors.fill: parent
        anchors.margins: root.cardPadding
        spacing: Config.appearance.spacing.small

        Rectangle {
            visible: root.popupMode
            Layout.preferredWidth: Config.appearance.sizes.urgencyStripe
            Layout.fillHeight: true
            radius: 2
            color: root.n.urgency === 2 ? Theme.red : root.n.urgency === 0 ? Theme.overlay0 : Theme.mauve

            Behavior on color {
                ColorAnim {}
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small / 2

            RowLayout {
                Layout.fillWidth: true
                spacing: Config.appearance.spacing.small

                Rectangle {
                    Layout.preferredWidth: Config.appearance.sizes.icon
                    Layout.preferredHeight: Config.appearance.sizes.icon
                    radius: Config.appearance.sizes.iconRadius
                    color: Theme.surface1

                    AppIcon {
                        anchors.centerIn: parent
                        width: Config.appearance.sizes.iconInner
                        height: Config.appearance.sizes.iconInner
                        source: root.n.icon
                    }
                }

                StyledText {
                    visible: root.popupMode
                    text: root.n.appName
                    color: Theme.blue
                    font.pixelSize: Config.appearance.fonts.size.tiny
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                StyledText {
                    visible: !root.popupMode
                    Layout.fillWidth: true
                    text: root.n.summary !== "" ? root.n.summary : root.n.appName
                    color: Theme.text
                    font.pixelSize: Config.appearance.fonts.size.medium
                    font.bold: true
                    elide: Text.ElideRight
                }

                StyledText {
                    text: root.n.timeStr
                    color: Theme.overlay0
                    font.pixelSize: Config.appearance.fonts.size.tiny
                }
            }

            StyledText {
                visible: root.popupMode && root.n.summary !== ""
                Layout.fillWidth: true
                text: root.n.summary
                color: Theme.text
                font.pixelSize: Config.appearance.fonts.size.medium
                font.bold: true
                elide: Text.ElideRight
            }

            StyledText {
                visible: root.n.body !== ""
                Layout.fillWidth: true
                text: root.n.body
                color: Theme.subtext1
                font.pixelSize: Config.appearance.fonts.size.small
                wrapMode: Text.WordWrap
                maximumLineCount: root.bodyMaxLines
                elide: Text.ElideRight
            }

            Rectangle {
                visible: root.popupMode && root.n.image !== "" && root.n.image !== root.n.appIcon
                Layout.fillWidth: true
                Layout.preferredHeight: Config.appearance.sizes.notificationImage
                radius: Config.appearance.rounding.small
                color: Theme.surface1
                clip: true

                Image {
                    anchors.fill: parent
                    source: parent.visible ? root.n.image : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            RowLayout {
                visible: root.n.actions.length > 0
                Layout.fillWidth: true
                spacing: Config.appearance.spacing.small / 2

                Repeater {
                    model: root.n.actions

                    delegate: Rectangle {
                        id: actionButton

                        required property var modelData

                        Layout.preferredHeight: Config.appearance.sizes.actionHeight
                        Layout.preferredWidth: actionLabel.implicitWidth + Config.appearance.padding.larger + Config.appearance.padding.smaller
                        radius: Config.appearance.rounding.small / 2
                        color: actionHover.hovered ? Theme.surface1 : Theme.surface0

                        Behavior on color {
                            ColorAnim {}
                        }

                        StyledText {
                            id: actionLabel

                            anchors.centerIn: parent
                            text: actionButton.modelData.label
                            color: Theme.blue
                            font.pixelSize: Config.appearance.fonts.size.tiny
                        }

                        HoverHandler {
                            id: actionHover
                        }

                        TapHandler {
                            onTapped: {
                                root.actionInvoked(actionButton.modelData.id);
                                if (root.popupMode)
                                    root.dismissed();
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: !root.popupMode && cardHover.hovered
            Layout.preferredWidth: Config.appearance.sizes.closeButton + 2
            Layout.preferredHeight: Config.appearance.sizes.closeButton + 2
            radius: (Config.appearance.sizes.closeButton + 2) / 2
            color: removeBtnTap.containsMouse ? Theme.surface2 : Theme.surface1

            MaterialSymbol {
                anchors.centerIn: parent
                text: "close"
                size: 14
                color: Theme.subtext1
            }

            TapHandler {
                id: removeBtnTap

                onTapped: root.dismissed()
            }
        }
    }

    Rectangle {
        visible: root.popupMode && cardHover.hovered
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Config.appearance.padding.smaller
        width: Config.appearance.sizes.closeButton
        height: Config.appearance.sizes.closeButton
        radius: Config.appearance.sizes.closeButtonRadius
        color: closeTap.containsMouse ? Theme.surface2 : Theme.surface1

        MaterialSymbol {
            anchors.centerIn: parent
            text: "close"
            size: 13
            color: Theme.subtext1
        }

        TapHandler {
            id: closeTap

            onTapped: root.dismissed()
        }
    }

    HoverHandler {
        id: cardHover
    }

    TapHandler {
        enabled: root.popupMode
        onTapped: root.dismissed()
    }
}
