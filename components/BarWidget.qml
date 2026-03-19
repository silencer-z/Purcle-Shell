import QtQuick

Rectangle {
    id: root

    property real borderWidth: 0
    property color borderColor: "transparent"

    property real paddingTop: 3
    property real paddingBottom: 3
    property real paddingLeft: 3
    property real paddingRight: 3

    property color widgetColor: "transparent"
    property real widgetRadius:0


    border.width: root.borderWidth
    border.color: root.borderColor

    default property alias data: content.data
    
    property alias widgetImplicitHeight: content.implicitHeight
    property alias widgetImplicitWidth: content.implicitWidth

    property alias widgetAnchors: content.anchors

    implicitWidth: content.implicitWidth + paddingLeft + paddingRight

    implicitHeight: content.implicitHeight + paddingBottom + paddingTop

    Rectangle {
        id: content
        anchors {
            top: parent.top;    topMargin: root.paddingTop
            bottom: parent.bottom; bottomMargin: root.paddingBottom
            left: parent.left;  leftMargin: root.paddingLeft
            right: parent.right; rightMargin: root.paddingRight
        }
        color:root.widgetColor
        radius:root.widgetRadius

        implicitWidth: children[0]?.implicitWidth ?? 0
        implicitHeight: children[0]?.implicitHeight ?? 0
    }
}