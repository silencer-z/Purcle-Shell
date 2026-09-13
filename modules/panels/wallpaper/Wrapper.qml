pragma ComponentBehavior: Bound

import qs.components
import qs.Configs
import qs.services
import QtQuick

// 左侧壁纸面板：从左缘滑入/滑出（x 位动画）
Item {
    id: root

    readonly property bool shouldBeActive: Visibilities.wallpaper

    // 满面板区高度
    readonly property int maxHeight: parent.height

    implicitWidth: content.item?.implicitWidth ?? 0
    height: root.maxHeight
    // x 不设绑定：绑定会压过动画写入（面板靠脚本 + 动画移动）
    x: 0
    anchors.top: parent.top

    onShouldBeActiveChanged: {
        if (shouldBeActive) {
            hideAnim.stop();
            // 懒加载：打开时同步实例化，滑动目标立即可用
            if (!content.active)
                content.active = true;
            // 起始位放在屏外（此时 item 已就绪）
            root.x = -((content.item?.implicitWidth ?? 0) + Config.appearance.padding.small);
            showAnim.start();
            focusTimer.restart();
        } else {
            showAnim.stop();
            hideAnim.start();
        }
    }

    Timer {
        id: focusTimer

        interval: 120
        repeat: false
        onTriggered: content.item?.focusInput?.()
    }

    SequentialAnimation {
        id: showAnim

        NumberAnim {
            target: root
            property: "x"
            to: 0
            // emphasizedDecel：无回弹，不过冲停靠位
            duration: Config.appearance.animations.durations.emphasizedDecel
            easing.bezierCurve: Config.appearance.animations.curves.emphasizedDecel
        }
    }

    SequentialAnimation {
        id: hideAnim

        NumberAnim {
            target: root
            property: "x"
            to: -((content.item?.implicitWidth ?? 0) + Config.appearance.padding.small)
            duration: Config.appearance.animations.durations.emphasized
            easing.bezierCurve: Config.appearance.animations.curves.emphasized
        }

        // 懒加载：滑出结束后卸载（guard 防 stop() 误卸载）
        onStopped: if (!root.shouldBeActive)
            content.active = false
    }

    Loader {
        id: content

        anchors.top: parent.top
        anchors.left: parent.left

        // 懒加载：默认不创建
        active: false
        sourceComponent: Content {
            maxHeight: root.maxHeight
        }

        onLoaded: {
            if (root.shouldBeActive)
                Qt.callLater(() => item.focusInput?.());
        }
    }
}
