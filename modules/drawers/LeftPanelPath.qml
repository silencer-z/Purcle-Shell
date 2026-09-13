import qs.components
import qs.Configs
import qs.services
import QtQuick
import QtQuick.Shapes

// 左侧满高面板：顶接 bar、左缘贴边、底接边框，右缘上下凹角
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
    startY: wrapper.y
    strokeWidth: -1
    fillColor: w > 1 && h > 1 ? root.surfaceColor : "transparent"

    PathLine {
        relativeX: root.w
        relativeY: 0
    }
    PathArc {
        relativeX: -root.rounding
        relativeY: root.roundingY
        radiusX: root.rounding
        radiusY: Math.min(root.rounding, root.h)
        direction: PathArc.Counterclockwise
    }
    PathLine {
        relativeX: 0
        relativeY: root.h - root.roundingY * 2
    }
    PathArc {
        relativeX: root.rounding
        relativeY: root.roundingY
        radiusX: root.rounding
        radiusY: Math.min(root.rounding, root.h)
        direction: PathArc.Counterclockwise
    }
    PathLine {
        relativeX: -root.w
        relativeY: 0
    }
    PathLine {
        relativeX: 0
        relativeY: -root.h
    }

    Behavior on surfaceColor {
        ColorAnim {}
    }
}
