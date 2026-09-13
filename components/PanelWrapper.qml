pragma ComponentBehavior: Bound

import qs.components
import qs.Configs
import qs.services
import QtQuick

// 通用面板壳：懒加载 + 展开/滑入动画。
// edge = bottom：改 implicitHeight（launcher / clipboard）
// edge = left/right：改 x（wallpaper / sidebar）
Item {
    id: root

    required property string panelName
    required property string edge
    required property Component contentComponent
    property int maxHeight: parent?.height ?? 0

    readonly property bool shouldBeActive: Visibilities.isOpen(root.panelName)
    readonly property int intrinsicHeight: content.item?.intrinsicHeight ?? 0
    readonly property int offscreenPad: Config.appearance.padding.small

    readonly property string animProperty: root.edge === "bottom" ? "implicitHeight" : "x"
    readonly property real showTo: {
        if (root.edge === "bottom")
            return root.contentHeight;
        if (root.edge === "left")
            return 0;
        return (parent?.width ?? 0) - root.implicitWidth;
    }
    readonly property real hideTo: {
        if (root.edge === "bottom")
            return 0;
        if (root.edge === "left")
            return -(root.implicitWidth + root.offscreenPad);
        return (parent?.width ?? 0) + root.offscreenPad;
    }

    property real contentHeight: 0
    property bool pendingShow: false

    visible: root.edge === "bottom" ? height > 0 : true
    clip: root.edge === "bottom"
    implicitWidth: content.item?.implicitWidth ?? 0
    implicitHeight: 0
    height: root.edge === "bottom" ? implicitHeight : root.maxHeight

    Component.onCompleted: root.bindHiddenX()

    function bindHiddenX(): void {
        if (root.edge === "right" && parent)
            root.x = Qt.binding(() => parent.width + root.offscreenPad);
        else if (root.edge === "left" && parent)
            root.x = Qt.binding(() => -(root.implicitWidth + root.offscreenPad));
    }

    function bindShownX(): void {
        if (root.edge === "right" && parent)
            root.x = Qt.binding(() => parent.width - root.implicitWidth);
        else if (root.edge === "left")
            root.x = 0;
    }

    function beginShow(): void {
        if (!root.shouldBeActive)
            return;

        hideAnim.stop();

        if (!content.active)
            content.active = true;

        if (content.status !== Loader.Ready) {
            root.pendingShow = true;
            return;
        }

        root.pendingShow = false;
        root.playShowAnimation();
    }

    function playShowAnimation(): void {
        if (root.edge === "bottom") {
            root.implicitHeight = 0;
            root.contentHeight = content.item?.implicitHeight ?? 0;
        } else if (root.edge === "left") {
            root.x = -(root.implicitWidth + root.offscreenPad);
        }

        showAnim.start();
        focusTimer.restart();
    }

    onShouldBeActiveChanged: {
        if (shouldBeActive) {
            beginShow();
        } else {
            root.pendingShow = false;
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
            property: root.animProperty
            to: root.showTo
            duration: root.edge === "bottom" ? Config.appearance.animations.durations.expressiveDefaultSpatial : Config.appearance.animations.durations.emphasizedDecel
            easing.bezierCurve: root.edge === "bottom" ? Config.appearance.animations.curves.expressiveDefaultSpatial : Config.appearance.animations.curves.emphasizedDecel
        }
        ScriptAction {
            script: {
                if (root.edge === "bottom")
                    root.implicitHeight = Qt.binding(() => content.item?.implicitHeight ?? 0);
                else
                    root.bindShownX();
            }
        }
    }

    SequentialAnimation {
        id: hideAnim

        ScriptAction {
            script: {
                if (root.edge === "bottom")
                    root.implicitHeight = root.implicitHeight;
            }
        }
        NumberAnim {
            target: root
            property: root.animProperty
            to: root.hideTo
            duration: Config.appearance.animations.durations.emphasized
            easing.bezierCurve: Config.appearance.animations.curves.emphasized
        }
        ScriptAction {
            script: {
                if (root.edge !== "bottom")
                    root.bindHiddenX();
            }
        }

        onStopped: {
            if (!root.shouldBeActive)
                content.active = false;
        }
    }

    Loader {
        id: content

        anchors.top: parent.top
        anchors.left: root.edge === "bottom" ? undefined : parent.left
        anchors.right: root.edge === "bottom" ? undefined : parent.right
        anchors.bottom: root.edge === "bottom" ? undefined : parent.bottom
        anchors.horizontalCenter: root.edge === "bottom" ? parent.horizontalCenter : undefined

        active: false
        sourceComponent: root.contentComponent

        onLoaded: {
            if (root.pendingShow)
                root.beginShow();
        }
    }
}
