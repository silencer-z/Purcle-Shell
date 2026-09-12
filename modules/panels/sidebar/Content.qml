pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

import "../widgets"
import qs.Configs
import qs.components
import qs.services

// 右侧统一面板（照 Popouts.qml 连体模式）：
// 顶边接 bar 底缘、右边贴屏幕右缘、底边接屏幕底边框 —— 三边均为连接边（方角），
// 左上/左下结合部用 RoundCorner 凹角圆弧过渡，使面板像从边框与 bar 的夹角"长"出来。
// 内容缩进避开左侧 fillet 区。
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

    // 左上结合部：凹角圆弧，连接 bar 底缘与面板左缘
    RoundCorner {
        corner: RoundCorner.CornerEnum.TopRight
        size: root.filletSize
        color: Theme.base
    }

    // 左下结合部：凹角圆弧，连接面板左缘与屏幕底边框
    RoundCorner {
        corner: RoundCorner.CornerEnum.BottomRight
        size: root.filletSize
        color: Theme.base

        anchors.left: parent.left
        anchors.bottom: parent.bottom
    }

    // 主体表面：四边均为连接边（方角）
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

    // 区块纵排：系统 / 滑块 / 连接 / 通知 / 日历 / 电量+会话
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
