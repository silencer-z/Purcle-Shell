pragma ComponentBehavior: Bound

import qs.Configs
import qs.components
import qs.services
import QtQuick
import Quickshell.Widgets

// Bar 组件弹出面板（caelestia popouts 效果）：
// 紧贴 bar 底缘（y = barHeight）且右缘贴屏幕右边缘，顶边与右边是连接边（方角），
// 左下为自由角（圆角）；左上结合部用 RoundCorner 凹角圆弧过渡，
// 使 popout 看起来像从 bar 与屏幕右缘的夹角处"长"出来。
// 尺寸切换动画锚定右缘（宽度向左展开、高度向下展开）。
Item {
    id: root

    property int barHeight: 0
    property int maxHeight: 0
    property real currentCenter: 0
    property string currentName: ""

    readonly property bool hasCurrent: currentName !== ""
    readonly property int contentPadding: Config.appearance.padding.normal
    readonly property int filletSize: Config.appearance.border.rounding

    function open(name: string, centerX: real): void {
        Visibilities.hideAll();
        root.currentName = name;
        root.currentCenter = centerX;
    }

    function close(): void {
        root.currentName = "";
    }

    focus: hasCurrent
    Keys.onEscapePressed: root.close()

    // 收起动画（高度收缩到 contentPadding*2）结束后再隐藏
    visible: root.hasCurrent || root.height > root.contentPadding * 2
    clip: true

    implicitWidth: root.filletSize + content.implicitWidth + root.contentPadding * 2
    implicitHeight: content.implicitHeight + root.contentPadding * 2

    // 右缘始终贴屏幕右边缘，宽度动画时左缘随之移动
    x: parent ? parent.width - root.width : 0
    y: root.barHeight

    Behavior on implicitWidth {
        NumberAnim {}
    }

    Behavior on implicitHeight {
        NumberAnim {}
    }

    // 左上结合部：凹角圆弧，连接 bar 底缘与 popout 左缘
    RoundCorner {
        corner: RoundCorner.CornerEnum.TopRight
        size: root.filletSize
        color: Theme.base
    }

    // 主体表面：顶角/右上/右下均为连接边（方角），仅左下自由角圆角
    ClippingRectangle {
        x: root.filletSize
        width: parent.width - root.filletSize
        height: parent.height

        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: Config.appearance.border.rounding
        bottomRightRadius: 0
        color: Theme.base
    }

    Content {
        id: content

        anchors.fill: parent
        anchors.leftMargin: root.filletSize + root.contentPadding
        anchors.rightMargin: root.contentPadding
        anchors.topMargin: root.contentPadding
        anchors.bottomMargin: root.contentPadding

        currentName: root.currentName
        maxHeight: root.maxHeight
        popouts: root
    }
}