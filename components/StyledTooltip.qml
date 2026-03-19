import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolTip {
    id: root
    property string content
    property bool extraVisibleCondition: true
    property bool alternativeVisibleCondition: false
    property bool internalVisibleCondition: {
        const ans = (extraVisibleCondition && (parent.hovered === undefined || parent?.hovered)) || alternativeVisibleCondition
        return ans
    }

    verticalPadding: 5
    horizontalPadding: 10
    opacity: internalVisibleCondition ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }

    background: null

    contentItem: Item {
        id: contentItemBackground
        // anchors.top: parent.bottom   // ⬅ 贴在父控件底部
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: tooltipTextObject.width + 2 * root.horizontalPadding
        implicitHeight: tooltipTextObject.height + 2 * root.verticalPadding

        Rectangle {
            id: backgroundRectangle
            anchors.bottom: contentItemBackground.bottom
            anchors.horizontalCenter: contentItemBackground.horizontalCenter
            color: "#3C4043"   // 固定颜色
            radius: 7
            width: internalVisibleCondition ? (tooltipTextObject.width + 2 * root.horizontalPadding) : 0
            height: internalVisibleCondition ? (tooltipTextObject.height + 2 * root.verticalPadding) : 0
            clip: true

            Behavior on width { NumberAnimation { duration: 150 } }
            Behavior on height { NumberAnimation { duration: 150 } }

            Text {
                id: tooltipTextObject
                anchors.centerIn: parent
                text: root.content
                font.pixelSize: 14
                color: "white"
                wrapMode: Text.Wrap
            }
        }
    }
}
