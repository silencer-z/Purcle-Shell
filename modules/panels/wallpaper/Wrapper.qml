pragma ComponentBehavior: Bound

import qs.components
import qs.Configs
import qs.services
import QtQuick

Item {
    id: root

    required property var panels

    readonly property bool shouldBeActive: Visibilities.wallpaper
    readonly property int intrinsicHeight: content.item?.intrinsicHeight ?? 0

    readonly property int maxHeight: {
        let max = parent.height - Config.appearance.padding.large;
        if (Visibilities.launcher)
            max -= panels.launcher.intrinsicHeight;
        if (Visibilities.clipboard)
            max -= panels.clipboard.intrinsicHeight;
        return Math.max(180, max);
    }

    property real contentHeight: 0

    visible: height > 0
    clip: true
    implicitHeight: 0
    implicitWidth: content.item?.implicitWidth ?? 0

    onShouldBeActiveChanged: {
        if (shouldBeActive) {
            root.contentHeight = content.item?.implicitHeight ?? 0;
            hideAnim.stop();
            showAnim.start();
            Qt.callLater(() => content.item?.focusInput?.());
        } else {
            showAnim.stop();
            hideAnim.start();
        }
    }

    SequentialAnimation {
        id: showAnim

        Anim {
            target: root
            property: "implicitHeight"
            to: root.contentHeight
            duration: Config.appearance.animations.durations.expressiveDefaultSpatial
            easing.bezierCurve: Config.appearance.animations.curves.expressiveDefaultSpatial
        }
        ScriptAction {
            script: root.implicitHeight = Qt.binding(() => content.item?.implicitHeight ?? 0)
        }
    }

    SequentialAnimation {
        id: hideAnim

        ScriptAction {
            script: root.implicitHeight = root.implicitHeight
        }
        Anim {
            target: root
            property: "implicitHeight"
            to: 0
            easing.bezierCurve: Config.appearance.animations.curves.emphasized
        }
    }

    Loader {
        id: content

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        active: true
        sourceComponent: Content {
            maxHeight: root.maxHeight
        }

        onLoaded: {
            if (root.shouldBeActive)
                Qt.callLater(() => item.focusInput?.());
        }
    }
}
