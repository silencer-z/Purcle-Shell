pragma ComponentBehavior: Bound

import qs.Configs
import qs.modules.drawers
import qs.services
import QtQuick
import QtQuick.Shapes

Shape {
    id: root

    required property var panels
    required property int barHeight
    property color surfaceColor: Theme.base

    readonly property real rounding: Config.appearance.border.rounding

    anchors.fill: parent
    anchors.margins: Config.appearance.border.thickness
    anchors.topMargin: root.barHeight
    preferredRendererType: Shape.CurveRenderer

    BottomPanelPath {
        wrapper: root.panels.launcher
        surfaceColor: root.surfaceColor
        startX: (root.width - wrapper.width) / 2 - root.rounding
        startY: root.height
    }

    BottomPanelPath {
        wrapper: root.panels.clipboard
        surfaceColor: root.surfaceColor
        startX: (root.width - wrapper.width) / 2 - root.rounding
        startY: root.panels.launcher.height > 0 ? root.panels.launcher.y : root.height
    }

    LeftPanelPath {
        wrapper: root.panels.wallpaper
        surfaceColor: root.surfaceColor
    }

    RightPanelPath {
        wrapper: root.panels.sidebar
        surfaceColor: root.surfaceColor
    }
}
