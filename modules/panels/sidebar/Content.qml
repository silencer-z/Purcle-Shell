pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

import "../widgets"
import qs.Configs
import qs.components
import qs.services

// 右侧面板：三边连接（bar/右缘/底边框），左上左下凹角过渡（同 Popouts 连体模式）
Item {
    id: root

    required property int maxHeight

    function close() {
        Visibilities.sidebar = false;
    }

    function focusInput() {
    }

    readonly property int filletSize: Config.appearance.border.rounding
    readonly property int contentPadding: Config.appearance.padding.normal
    readonly property int bodyWidth: 420

    implicitWidth: root.filletSize + root.bodyWidth + root.contentPadding * 2
    implicitHeight: root.maxHeight

    // 左上凹角：接 bar 底缘
    RoundCorner {
        corner: RoundCorner.CornerEnum.TopRight
        size: root.filletSize
        color: Theme.base
    }

    // 左下凹角：接屏幕底边框
    RoundCorner {
        corner: RoundCorner.CornerEnum.BottomRight
        size: root.filletSize
        color: Theme.base

        anchors.left: parent.left
        anchors.bottom: parent.bottom
    }

    // 主体：四边方角
    ClippingRectangle {
        x: root.filletSize
        width: parent.width - root.filletSize
        height: parent.height

        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: 0
        bottomRightRadius: 0
        color: Theme.base

        Behavior on color {
            ColorAnim {}
        }
    }

    // 区块纵排
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: root.filletSize + root.contentPadding
        anchors.rightMargin: root.contentPadding
        anchors.topMargin: root.contentPadding
        anchors.bottomMargin: root.contentPadding
        spacing: Config.appearance.spacing.small

        SystemSection {
            Layout.fillWidth: true
        }

        QuickSliders {
            Layout.fillWidth: true
        }

        ConnectSection {
            Layout.fillWidth: true
        }

        NotificationWidget {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 160
        }

        CalendarSection {
            Layout.fillWidth: true
        }

        BottomSection {
            Layout.fillWidth: true
        }
    }
}
