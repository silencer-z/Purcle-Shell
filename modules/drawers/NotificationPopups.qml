pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Configs
import qs.components
import qs.services

// 通知弹层：与 bar popout 同构——顶/右贴边、左上凹角连体 bar，左下自由圆角。
Item {
    id: root

    property int barHeight: 0

    readonly property int contentPadding: Config.appearance.padding.normal
    readonly property int filletSize: Config.appearance.border.rounding
    readonly property int cardWidth: Config.appearance.sizes.panelSide - Config.appearance.border.rounding
    readonly property int minChromeHeight: root.contentPadding * 2

    property real stableContentHeight: 0

    implicitWidth: root.filletSize + root.cardWidth + root.contentPadding * 2
    implicitHeight: root.stableContentHeight + root.contentPadding * 2

    width: implicitWidth
    height: implicitHeight

    x: parent ? parent.width - root.width : 0
    y: root.barHeight

    visible: popupList.count > 0 || root.height > root.minChromeHeight + 1
    clip: true

    Behavior on implicitHeight {
        NumberAnim {}
    }

    Timer {
        id: shrinkTimer

        interval: Config.appearance.animations.durations.small
        repeat: false
        onTriggered: root.stableContentHeight = 0
    }

    function syncContentHeight(): void {
        if (popupList.count > 0) {
            shrinkTimer.stop();
            root.stableContentHeight = popupList.contentHeight;
        } else if (!shrinkTimer.running) {
            shrinkTimer.restart();
        }
    }

    RoundCorner {
        corner: RoundCorner.CornerEnum.TopRight
        size: root.filletSize
        color: Theme.base
    }

    ClippingRectangle {
        x: root.filletSize
        width: parent.width - root.filletSize
        height: parent.height

        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: Config.appearance.border.rounding
        bottomRightRadius: 0
        color: Theme.base

        Behavior on color {
            ColorAnim {}
        }
    }

    ListView {
        id: popupList

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: root.filletSize + root.contentPadding
        anchors.rightMargin: root.contentPadding
        anchors.topMargin: root.contentPadding

        width: root.cardWidth
        height: root.stableContentHeight
        spacing: Config.appearance.spacing.small
        interactive: false
        clip: false

        model: Notifications.popupModel

        onCountChanged: root.syncContentHeight()
        onContentHeightChanged: root.syncContentHeight()

        add: Transition {
            ParallelAnimation {
                PropertyAction {
                    property: "slideProgress"
                    value: 0
                }
                PropertyAction {
                    property: "opacity"
                    value: 0
                }
                NumberAnimation {
                    property: "slideProgress"
                    to: 1
                    duration: Config.appearance.animations.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Config.appearance.animations.curves.emphasizedDecel
                }
                NumberAnimation {
                    property: "opacity"
                    to: 1
                    duration: Config.appearance.animations.durations.small
                }
            }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: Config.appearance.animations.durations.small
                }
                NumberAnimation {
                    property: "slideProgress"
                    to: 0
                    duration: Config.appearance.animations.durations.small
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Config.appearance.animations.curves.emphasizedAccel
                }
            }
        }

        displaced: Transition {
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

            property real slideProgress: 1

            width: popupList.width
            implicitHeight: card.implicitHeight
            x: (1 - slideProgress) * Config.appearance.spacing.large

            NotificationCard {
                id: card

                width: parent.width
                popupMode: true
                notification: popupCard.wrapper
                onDismissed: Notifications.dismiss(popupCard.wrapper)
                onActionInvoked: (actionId) => popupCard.wrapper.invoke(actionId)
            }
        }
    }
}
