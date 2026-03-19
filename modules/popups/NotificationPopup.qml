import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs.services
import qs.components 


PanelWindow {
    id: root
    
    anchors {
        top: true
        right: true
    }

    implicitWidth: 360
    implicitHeight: popupList.height + 24

    aboveWindows:true
    exclusionMode: ExclusionMode.Normal
    color: "transparent"

    ListView {
        id: popupList
        anchors.top:parent.top
        anchors.left:parent.left
        anchors.right:parent.right
        anchors.margins: 6

        height: contentHeight
        width: parent.width - 24
        
        model: NoticeService.popupModel
        
        spacing: 12
        interactive: true
        
        verticalLayoutDirection: ListView.TopToBottom

        // 简单的淡入淡出动画
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250 }
        }

        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: 200 }
        }

        addDisplaced: Transition {
            NumberAnimation { properties: "y"; duration: 200; easing.type: Easing.OutQuad }
        }

        removeDisplaced: Transition {
            NumberAnimation { properties: "y"; duration: 200; easing.type: Easing.OutQuad }
        }

        delegate: Item {
            implicitWidth: popupList.width
            implicitHeight:contentRect.height
            
            property var n: model.wrapper

            Rectangle {
                id: contentRect
                width: parent.width
                height: innerLayout.implicitHeight + 24
                radius: 16
                
                color: mouseArea.containsMouse ? "#262638" : "#1e1e2e" // Base
                border.color: "#313244" // Surface0

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                border.width: 1
                

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: NoticeService.removeSeq(n.seq)
                    onPressed: (mouse) => {
                        if (mouse.button === Qt.RightButton) NoticeService.clearAll()
                    }
                }

                ColumnLayout {
                    id: innerLayout
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // 上半部分：Icon + Title + Time
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        // 大图标
                        Rectangle {
                            Layout.preferredWidth: 42
                            Layout.preferredHeight: 42
                            radius: 12
                            color: "#313244" // Surface0 backdrop for icon
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 4
                                source: (n.appIcon || n.image) ? (n.appIcon || n.image) : Quickshell.shellPath("assets/default.svg")
                                fillMode: Image.PreserveAspectFit
                                sourceSize: Qt.size(64, 64)
                            }
                        }

                        // 文本信息
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: n.appName
                                    font.bold: true
                                    font.pixelSize: 11
                                    color: "#89b4fa" // Blue
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: n.timeStr
                                    font.pixelSize: 10
                                    color: "#6c7086" // Overlay0
                                }
                            }

                            Text {
                                text: n.summary
                                Layout.fillWidth: true
                                color: "#cdd6f4" // Text
                                font.bold: true
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // 下半部分：Body
                    Text {
                        visible: text !== ""
                        text: n.body
                        Layout.fillWidth: true
                        Layout.leftMargin: 54 // 对齐文字部分
                        color: "#a6adc8" // Subtext0
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                    
                    // 图片预览 (如果有大图，且不是图标)
                    Rectangle {
                        visible: n.image && n.image !== n.appIcon
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        Layout.topMargin: 4
                        color: "#313244"
                        radius: 8
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: parent.visible ? n.image : ""
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    // 底部：操作按钮 (如果有)
                    RowLayout {
                        visible: n.actions && n.actions.length > 0
                        Layout.fillWidth: true
                        Layout.leftMargin: 54
                        spacing: 8
                        
                        Repeater {
                            model: n.actions
                            delegate: Rectangle {
                                Layout.preferredHeight: 24
                                Layout.preferredWidth: actionLabel.implicitWidth + 16
                                radius: 6
                                color: actionMouse.containsMouse ? "#45475a" : "transparent"
                                border.color: "#45475a"
                                
                                Text {
                                    id: actionLabel
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.pixelSize: 11
                                    color: "#89b4fa"
                                }
                                MouseArea {
                                    id: actionMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: n.invoke(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}