pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets

 
Slider {
    id: root

    property list<real> stopIndicatorValues: [1]
    enum Configuration {
        XS = 12,
        S = 18,
        M = 30,
        L = 42,
        XL = 72
    }

    property var configuration: StyledSlider.Configuration.XS

    property real handleDefaultWidth: 3
    property real handlePressedWidth: 1.5

    property color highlightColor: "#89b4fa"
    property color trackColor: "#313244"
    property color handleColor: "#cba6f7"
    property color dotColor: "#6c7086"
    property color dotColorHighlighted: "#89b4fa"

    property real unsharpenRadius: 6
    property real trackWidth: configuration
    property real trackRadius: trackWidth >= StyledSlider.Configuration.XL ? 21
        : trackWidth >= StyledSlider.Configuration.L ? 12
        : trackWidth >= StyledSlider.Configuration.M ? 9
        : 6
    // property real handleHeight: Math.max(33, trackWidth + 9)
    property real handleHeight:trackWidth+9
    property real handleWidth: root.pressed ? handlePressedWidth : handleDefaultWidth
    property real handleMargins: 4
    property bool userUpdating: false
    property real trackDotSize: 3
    property string tooltipContent: `${Math.round(value * 100)}%`

    leftPadding: handleMargins
    rightPadding: handleMargins
    property real effectiveDraggingWidth: width - leftPadding - rightPadding

    Layout.fillWidth: true
    from: 0
    to: 1

    Behavior on value {
        enabled: !root.pressed
        SmoothedAnimation {
            velocity: 200
        }
    }

    Behavior on handleMargins {
        animation: NumberAnimation{duration:150}
    }

    component TrackDot: Rectangle {
        required property real value
        anchors.verticalCenter: parent.verticalCenter
        x: root.handleMargins + (value * root.effectiveDraggingWidth) - (root.trackDotSize / 2)
        width: root.trackDotSize
        height: root.trackDotSize
        radius: width/2
        color: value > root.visualPosition ? root.dotColor : root.dotColorHighlighted

        Behavior on color {
            animation: ColorAnimation{duration:150}
        }
    }

    background: Item {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        implicitHeight: root.trackWidth
        
        // Fill left
        Rectangle {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            width: root.handleMargins + (root.visualPosition * root.effectiveDraggingWidth) - (root.handleWidth / 2 + root.handleMargins)
            height: root.trackWidth
            color: root.highlightColor
            topLeftRadius: root.trackRadius
            bottomLeftRadius: root.trackRadius
            topRightRadius: root.unsharpenRadius
            bottomRightRadius: root.unsharpenRadius
        }

        // Fill right
        Rectangle {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
            width: root.handleMargins + ((1 - root.visualPosition) * root.effectiveDraggingWidth) - (root.handleWidth / 2 + root.handleMargins)
            height: root.trackWidth
            color: root.trackColor
            topRightRadius: root.trackRadius
            bottomRightRadius: root.trackRadius
            topLeftRadius: root.unsharpenRadius
            bottomLeftRadius: root.unsharpenRadius
        }

        // Stop indicators
        Repeater {
            model: root.stopIndicatorValues
            TrackDot {
                required property real modelData
                value: modelData
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: (event) => {
                const pos = event.position.x - root.leftPadding;
                const ratio = Math.max(0, Math.min(1, pos / root.effectiveDraggingWidth));
                root.value = ratio;
                event.accepted = true;
            }
        }
    }

    handle: Rectangle {
        id: handle

        implicitWidth: root.handleWidth
        implicitHeight: root.handleHeight
        x: root.handleMargins + (root.visualPosition * root.effectiveDraggingWidth) - (root.handleWidth / 2)
        anchors.verticalCenter: parent.verticalCenter
        radius: width/2
        color: root.handleColor

        Behavior on implicitWidth {
            animation: NumberAnimation{duration:150}
        }

        StyledTooltip {
            extraVisibleCondition: root.pressed
            content: root.tooltipContent
        }
    }
}