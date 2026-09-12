pragma ComponentBehavior: Bound

import qs.components
import qs.Configs
import qs.services
import QtQuick

// 右侧统一面板 Wrapper：贴面板区右缘、顶缘，
// 打开时从右向左滑入，关闭时滑出（x 位动画，几何与内容一体）。
Item {
    id: root

    readonly property bool shouldBeActive: Visibilities.sidebar

    // 面板总高：满面板区高度（顶接 bar 底缘、底接屏幕底边框）
    readonly property int maxHeight: parent.height

    implicitWidth: content.item?.implicitWidth ?? 0
    height: root.maxHeight
    // 关闭态停在右缘外（普通声明绑定：随窗口尺寸变化自动更新，
    // 注意不要用 Qt.binding() 声明式写法——那只在创建时求值一次不跟踪依赖）
    x: parent.width + Config.appearance.padding.small
    anchors.top: parent.top

    onShouldBeActiveChanged: {
        if (shouldBeActive) {
            hideAnim.stop();
            // 懒加载：打开时同步实例化（implicitWidth 立即可用，滑动目标位置正确）
            if (!content.active)
                content.active = true;
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
            to: root.parent.width - root.implicitWidth
            // emphasizedDecel：无回弹（不会过冲停靠位），强减速顺滑落定
            duration: Config.appearance.animations.durations.emphasizedDecel
            easing.bezierCurve: Config.appearance.animations.curves.emphasizedDecel
        }
        // 动画结束后恢复停靠位的绑定（窗口尺寸变化时跟随）
        ScriptAction {
            script: root.x = Qt.binding(() => root.parent.width - root.implicitWidth)
        }
    }

    SequentialAnimation {
        id: hideAnim

        NumberAnim {
            target: root
            property: "x"
            to: root.parent.width + Config.appearance.padding.small
            duration: Config.appearance.animations.durations.emphasized
            easing.bezierCurve: Config.appearance.animations.curves.emphasized
        }
        // 动画结束后恢复隐藏位的绑定（JS 侧 Qt.binding 赋值是官方用法，依赖跟踪正常）
        ScriptAction {
            script: root.x = Qt.binding(() => root.parent.width + Config.appearance.padding.small)
        }

        // 懒加载：滑出动画自然结束后卸载内容（stop() 中断不卸载，由 guard 保证）
        onStopped: if (!root.shouldBeActive)
            content.active = false
    }

    Loader {
        id: content

        anchors.top: parent.top
        anchors.left: parent.left

        // 懒加载：默认不创建，由 onShouldBeActiveChanged / hideAnim.onStopped 管理
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
