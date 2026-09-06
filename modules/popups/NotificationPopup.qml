pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Configs
import qs.components
import qs.services

// 通知弹窗：右上角层叠卡片，从顶部滑入；紧急度色条 + 应用图标 + 正文 + 操作按钮
PanelWindow {
    id: root

    WlrLayershell.namespace: "PurcleShell-notifications"

    anchors.top: true
    anchors.right: true

    implicitWidth: 380
    implicitHeight: popupList.contentHeight + Config.appearance.margin.large * 2

    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    ListView {
        id: popupList

        anchors.fill: parent
        anchors.margins: Config.appearance.margin.large

        // BottomToTop：模型尾部（最新）在最上方，旧卡片向下推移
        verticalLayoutDirection: ListView.BottomToTop
        spacing: Config.appearance.spacing.small
        interactive: false
        clip: true

        model: Notifications.popupModel

        add: Transition {
            SequentialAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Config.appearance.animations.durations.small
                }
                NumberAnimation {
                    property: "slideProgress"
                    from: 0
                    to: 1
                    duration: Config.appearance.animations.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Config.appearance.animations.curves.emphasizedDecel
                }
            }
        }

        remove: Transition {
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: Config.appearance.animations.durations.small
            }
        }

        addDisplaced: Transition {
            NumberAnimation {
                property: "y"
                duration: Config.appearance.animations.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Config.appearance.animations.curves.emphasized
            }
        }

        removeDisplaced: Transition {
            NumberAnimation {
                property: "y"
                duration: Config.appearance.animations.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Config.appearance.animations.curves.emphasized
            }
        }

        delegate: Item {
            id: popupCard

            required property var wrapper

            readonly property var n: wrapper
            property real slideProgress: 1
            // 滑入偏移（slideProgress: 0→1 从右移入到位）
            x: (1 - slideProgress) * (width / 3 + 12)
            opacity: slideProgress > 0.99 ? 1 : slideProgress

            implicitWidth: popupList.width
            implicitHeight: card.implicitHeight

            Rectangle {
                id: card

                width: parent.width
                implicitHeight: content.implicitHeight + Config.appearance.padding.larger * 2
                radius: Config.appearance.rounding.normal
                color: Theme.base
                border.width: 1
                border.color: Theme.surface0

                Behavior on color {
                    ColorAnim {}
                }

                RowLayout {
                    id: content

                    anchors.fill: parent
                    anchors.margins: Config.appearance.padding.larger
                    spacing: Config.appearance.spacing.small

                    // ==== 紧急度色条 ====
                    Rectangle {
                        Layout.preferredWidth: 4
                        Layout.fillHeight: true
                        radius: 2
                        color: popupCard.n.urgency === 2 ? Theme.red : popupCard.n.urgency === 0 ? Theme.overlay0 : Theme.mauve

                        Behavior on color {
                            ColorAnim {}
                        }
                    }

                    // ==== 主体 ====
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Config.appearance.spacing.small / 2

                        // 应用图标 + 名称 + 时间
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Config.appearance.spacing.small

                            Rectangle {
                                Layout.preferredWidth: 34
                                Layout.preferredHeight: 34
                                radius: 10
                                color: Theme.surface0

                                IconImage {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    source: {
                                        const s = popupCard.n.appIcon || popupCard.n.image;
                                        return s !== "" ? s : "file://" + Quickshell.shellPath("assets/default.svg");
                                    }
                                    implicitSize: 32
                                }
                            }

                            StyledText {
                                text: popupCard.n.appName
                                color: Theme.blue
                                font.pixelSize: 11
                                font.bold: true

                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: popupCard.n.timeStr
                                color: Theme.overlay0
                                font.pixelSize: 11
                            }
                        }

                        // 标题
                        StyledText {
                            visible: popupCard.n.summary !== ""
                            Layout.fillWidth: true
                            text: popupCard.n.summary
                            color: Theme.text
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        // 正文（最多两行）
                        StyledText {
                            visible: popupCard.n.body !== ""
                            Layout.fillWidth: true
                            text: popupCard.n.body
                            color: Theme.subtext1
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        // 图片预览
                        Rectangle {
                            visible: popupCard.n.image !== "" && popupCard.n.image !== popupCard.n.appIcon
                            Layout.fillWidth: true
                            Layout.preferredHeight: 110
                            radius: Config.appearance.rounding.small
                            color: Theme.surface0
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: parent.visible ? popupCard.n.image : ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                        }

                        // 操作按钮
                        RowLayout {
                            visible: popupCard.n.actions.length > 0
                            Layout.fillWidth: true
                            spacing: Config.appearance.spacing.small / 2

                            Repeater {
                                model: popupCard.n.actions

                                delegate: Rectangle {
                                    id: actionButton

                                    required property var modelData

                                    Layout.preferredHeight: 26
                                    Layout.preferredWidth: actionLabel.implicitWidth + 20
                                    radius: 8
                                    color: actionHover.hovered ? Theme.surface1 : Theme.surface0

                                    Behavior on color {
                                        ColorAnim {}
                                    }

                                    StyledText {
                                        id: actionLabel

                                        anchors.centerIn: parent
                                        text: actionButton.modelData.label
                                        color: Theme.blue
                                        font.pixelSize: 11
                                    }

                                    HoverHandler {
                                        id: actionHover
                                    }

                                    TapHandler {
                                        onTapped: {
                                            popupCard.n.invoke(actionButton.modelData.id);
                                            Notifications.dismiss(popupCard.n);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // 悬停关闭按钮
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 6
                    width: 22
                    height: 22
                    radius: 11
                    visible: cardHover.hovered
                    color: closeTap.containsMouse ? Theme.surface2 : Theme.surface1

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "close"
                        size: 14
                        color: Theme.subtext1
                    }

                    TapHandler {
                        id: closeTap

                        onTapped: Notifications.dismiss(popupCard.n)
                    }
                }

                HoverHandler {
                    id: cardHover
                }

                // 点击卡片收起弹窗
                TapHandler {
                    onTapped: Notifications.dismiss(popupCard.n)
                }
            }
        }
    }
}
