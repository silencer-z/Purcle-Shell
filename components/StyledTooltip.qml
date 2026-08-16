import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.services

ToolTip {
    id: root

    property string content
    property bool extraVisibleCondition: true
    property bool alternativeVisibleCondition: false
    property bool internalVisibleCondition: {
        const ans = (extraVisibleCondition && (parent.hovered === undefined || parent?.hovered)) || alternativeVisibleCondition
        return ans
    }

    // 定位：水平居中于父控件，垂直在父控件下方
    x: parent ? (parent.width - implicitWidth) / 2 : 0
    y: parent ? parent.height + 4 : 0

    verticalPadding: 6
    horizontalPadding: 10
    delay: 200
    opacity: internalVisibleCondition ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }

    background: Rectangle {
        color: Theme.surface1
        radius: 7
        border.color: Theme.surface2
        border.width: 1
    }

    contentItem: Text {
        text: root.content
        color: Theme.text
        font.pixelSize: 14
        wrapMode: Text.Wrap
    }
}
