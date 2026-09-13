pragma ComponentBehavior: Bound

import qs.components
import qs.Configs
import qs.services
import QtQuick

// 右侧面板：从右缘滑入/滑出（x 位动画）
Item {
    id: root

    readonly property bool shouldBeActive: Visibilities.sidebar

    // 满面板区高度
    readonly property int maxHeight: parent.height

    implicitWidth: content.item?.implicitWidth ?? 0
    height: root.maxHeight
    // 关闭态停在右缘外（勿用声明式 Qt.binding：只求值一次不跟踪依赖）
    x: parent.width + Config.appearance.padding.small
    anchors.top: parent.top

    onShouldBeActiveChanged: {
        if (shouldBeActive) {
            hideAnim.stop();
            // 懒加载：打开时同步实例化，滑动目标立即可用
            if (!content.active)
                content.active = true;
            showAnim.start();
        } else {
            showAnim.stop();
            hideAnim.start();
        }
    }

    SequentialAnimation {
        id: showAnim

        NumberAnim {
            target: root
            property: "x"
            to: root.parent.width - root.implicitWidth
            // emphasizedDecel：无回弹，不过冲停靠位
            duration: Config.appearance.animations.durations.emphasizedDecel
            easing.bezierCurve: Config.appearance.animations.curves.emphasizedDecel
        }
        // 结束后恢复绑定（窗口尺寸变化时跟随）
        ScriptAction {
            script: {
                root.x = Qt.binding(() => root.parent.width - root.implicitWidth);
                if (root.shouldBeActive)
                    Qt.callLater(() => content.item?.focusInput?.());
            }
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
        // 结束后恢复隐藏位绑定（JS 侧 Qt.binding 赋值才跟踪依赖）
        ScriptAction {
            script: root.x = Qt.binding(() => root.parent.width + Config.appearance.padding.small)
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
    }
}
