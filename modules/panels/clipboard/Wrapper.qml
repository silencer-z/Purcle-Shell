pragma ComponentBehavior: Bound

import qs.components
import qs.Configs
import qs.services
import QtQuick

Item {
    id: root

    required property var panels

    readonly property bool shouldBeActive: Visibilities.clipboard
    readonly property int intrinsicHeight: content.item?.intrinsicHeight ?? 0

    readonly property int maxHeight: {
        let max = parent.height - Config.appearance.padding.large;
        if (Visibilities.launcher)
            max -= panels.launcher.intrinsicHeight;
        return Math.max(180, max);
    }

    property real contentHeight: 0

    visible: height > 0
    clip: true
    implicitHeight: 0
    implicitWidth: content.item?.implicitWidth ?? 0

    onShouldBeActiveChanged: {
        if (shouldBeActive) {
            // 懒加载：打开时同步实例化，展开目标立即可用
            if (!content.active)
                content.active = true;
            root.contentHeight = content.item?.implicitHeight ?? 0;
            hideAnim.stop();
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
            property: "implicitHeight"
            to: root.contentHeight
            duration: Config.appearance.animations.durations.expressiveDefaultSpatial
            easing.bezierCurve: Config.appearance.animations.curves.expressiveDefaultSpatial
        }
        ScriptAction {
            script: {
                root.implicitHeight = Qt.binding(() => content.item?.implicitHeight ?? 0);
                if (root.shouldBeActive)
                    Qt.callLater(() => content.item?.focusInput?.());
            }
        }
    }

    SequentialAnimation {
        id: hideAnim

        ScriptAction {
            script: root.implicitHeight = root.implicitHeight
        }
        NumberAnim {
            target: root
            property: "implicitHeight"
            to: 0
            easing.bezierCurve: Config.appearance.animations.curves.emphasized
        }

        // 懒加载：收起结束后卸载
        onStopped: if (!root.shouldBeActive)
            content.active = false
    }

    Loader {
        id: content

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        // 懒加载：默认不创建
        active: false
        sourceComponent: Content {
            maxHeight: root.maxHeight
        }
    }
}
