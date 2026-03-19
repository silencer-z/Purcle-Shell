import QtQuick
import QtQuick.Controls


ProgressBar {
    id: root
    property real valueBarWidth: 120
    property real valueBarHeight: 4
    property real valueBarGap: 4
    property color highlightColor: "#685496"
    property color trackColor: "#F1D3F9"
    property bool sperm: false
    property bool animateSperm: true
    property real spermAmplitudeMultiplier: sperm ? 0.5 : 0
    property real spermFrequency: 6
    property real spermFps: 60

    property bool showEndCap: true
    property real borderRadius: 9999
    property bool enableValueAnimation: true // Enable smooth value transitions
    property int animationDuration: 150 // Duration of value change animations
    property color endCapColor: highlightColor // Color of the end cap circle
    property bool enableHoverEffect: false // Enable hover-based color changes
    property color hoverHighlightColor: highlightColor // Highlight color on hover
    property real controlOpacity: 1.0 // Overall opacity

    // Internal hover state - set by parent component
    property bool hoveredInternal: false

    // Value animation behavior
    Behavior on value {
        enabled: enableValueAnimation
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    // Opacity behavior
    Behavior on opacity {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }

    
    background: Item {
        anchors.fill: parent
        implicitHeight: valueBarHeight
        implicitWidth: valueBarWidth
    }

    contentItem: Item {
        anchors.fill: parent
        opacity: root.controlOpacity

        // Standard fill
        Rectangle {
            id: standardFill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * root.visualPosition
            radius: root.borderRadius
            color: root.enableHoverEffect && root.hoveredInternal ? root.hoverHighlightColor : root.highlightColor

            Behavior on width {
                enabled: root.enableValueAnimation
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Right remaining part fill
        Rectangle {
            id: trackFill
            anchors.right: parent.right
            width: (1 - root.visualPosition) * parent.width - (root.showEndCap ? root.valueBarGap : 0)
            height: parent.height
            radius: root.borderRadius
            color: root.trackColor

            Behavior on width {
                enabled: root.enableValueAnimation
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
        }

        // End cap circle
        Rectangle {
            anchors.right: parent.right
            width: root.showEndCap ? root.valueBarGap : 0
            height: root.showEndCap ? root.valueBarGap : 0
            radius: root.showEndCap ? root.borderRadius : 0
            color: root.showEndCap ? root.endCapColor : "transparent"
            visible: root.showEndCap

            Behavior on color {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}