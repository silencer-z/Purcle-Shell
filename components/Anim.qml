import qs.Configs
import QtQuick

NumberAnimation {
    duration: Config.appearance.animations.durations.normal
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Config.appearance.animations.curves.standard
}
