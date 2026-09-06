import qs.Configs
import QtQuick

ColorAnimation {
    duration: Config.appearance.animations.durations.normal
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Config.appearance.animations.curves.standard
}
