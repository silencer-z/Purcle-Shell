import qs.components
import qs.Configs
import qs.services
import QtQuick
import QtQuick.Shapes

// 底边满宽面板：底/左/右贴边，顶缘左右凹角（LeftPanelPath 右转 90°：凹角加在矩形上方，不是从矩形挖角）
ShapePath {
    id: root

    required property Item wrapper
    property color surfaceColor: Theme.base

    readonly property real rounding: Config.appearance.border.rounding
    readonly property real w: wrapper.width
    readonly property real h: wrapper.height
    readonly property bool flatten: h < rounding * 2
    readonly property real roundingY: flatten ? h / 2 : rounding

    startX: wrapper.x
    startY: wrapper.y + root.h
    strokeWidth: -1
    fillColor: w > 1 && h > 1 ? root.surfaceColor : "transparent"

    PathLine {
        relativeX: 0
        relativeY: -root.h
    }
    PathArc {
        relativeX: root.rounding
        relativeY: root.roundingY
        radiusX: root.rounding
        radiusY: Math.min(root.rounding, root.h)
        direction: PathArc.Counterclockwise
    }
    PathLine {
        relativeX: root.w - root.rounding * 2
        relativeY: 0
    }
    PathArc {
        relativeX: root.rounding
        relativeY: -root.roundingY
        radiusX: root.rounding
        radiusY: Math.min(root.rounding, root.h)
        direction: PathArc.Counterclockwise
    }
    PathLine {
        relativeX: 0
        relativeY: root.h
    }
    PathLine {
        relativeX: -root.w
        relativeY: 0
    }

    Behavior on surfaceColor {
        ColorAnim {}
    }
}
