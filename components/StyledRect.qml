import QtQuick

Rectangle {
    id: root

    color: "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.BezierSpline
        }

    }

}
