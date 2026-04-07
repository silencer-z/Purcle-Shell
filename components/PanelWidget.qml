import QtQuick

Rectangle {
    id: root

    property real paddingTop: 3
    property real paddingBottom: 3
    property real paddingLeft: 3
    property real paddingRight: 3
    default property alias data: content.data

    color: "transparent"
    radius: 10
    implicitWidth: content.implicitWidth + paddingLeft + paddingRight
    implicitHeight: content.implicitHeight + paddingBottom + paddingTop

    Item {
        id: content

        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height

        anchors {
            top: parent.top
            topMargin: root.paddingTop
            bottom: parent.bottom
            bottomMargin: root.paddingBottom
            left: parent.left
            leftMargin: root.paddingLeft
            right: parent.right
            rightMargin: root.paddingRight
        }

    }

}
