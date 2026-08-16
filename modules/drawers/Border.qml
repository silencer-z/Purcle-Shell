pragma ComponentBehavior: Bound

import qs.Configs
import qs.components
import qs.services
import QtQuick
import QtQuick.Effects

Item {
    id: root

    required property int barHeight

    anchors.fill: parent

    StyledRect {
        anchors.fill: parent
        color: Theme.surface1

        layer.enabled: true
        layer.effect: MultiEffect {
            maskSource: mask
            maskEnabled: true
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
        }
    }

    Item {
        id: mask

        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            anchors.margins: Config.appearance.border.thickness
            anchors.topMargin: root.barHeight
            radius: Config.appearance.border.rounding
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: root.barHeight
        }
    }
}
