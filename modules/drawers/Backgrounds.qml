pragma ComponentBehavior: Bound

import qs.Configs
import qs.modules.panels.launcher as Launcher
import qs.modules.panels.clipboard as Clipboard
import qs.modules.panels.wallpaper as Wallpaper
import qs.services
import QtQuick
import QtQuick.Shapes

Shape {
    id: root

    required property var panels
    required property int barHeight
    property color surfaceColor: Theme.base

    anchors.fill: parent
    anchors.margins: Config.appearance.border.thickness
    anchors.topMargin: root.barHeight
    preferredRendererType: Shape.CurveRenderer

    Launcher.Background {
        wrapper: root.panels.launcher
        surfaceColor: root.surfaceColor

        startX: (root.width - wrapper.width) / 2 - rounding
        startY: root.height
    }

    Clipboard.Background {
        wrapper: root.panels.clipboard
        surfaceColor: root.surfaceColor

        startX: (root.width - wrapper.width) / 2 - rounding
        startY: root.panels.launcher.height > 0 ? root.panels.launcher.y : root.height
    }

    Wallpaper.Background {
        wrapper: root.panels.wallpaper
        surfaceColor: root.surfaceColor

        startX: (root.width - wrapper.width) / 2 - rounding
        startY: root.panels.clipboard.height > 0 ? root.panels.clipboard.y : (root.panels.launcher.height > 0 ? root.panels.launcher.y : root.height)
    }
}
