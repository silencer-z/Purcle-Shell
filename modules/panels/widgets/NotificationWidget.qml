import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.services 
import qs.components


PanelWidget {
    id: root
    height: 600
    width: 400
    color: "#313244"
    border.color: "#45475a"
    radius: 20

    // ---------------- 主要布局 ----------------
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 0 

        // --- 标题栏 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 10
            spacing: 8

            IconText {
                text: "notifications"
                size: 20;
                color: NoticeService.historyModel.count > 0 ? "#f9e2af" : "#a6adc8"
            }

            Text {
                text: "Notifications"
                font.pixelSize: 16
                font.bold: true
                color: "#cdd6f4"
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true } // 弹簧

            // DND 开关
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 14
                color: NoticeService.doNotDisturb ? "#f38ba8" : "#45475a"
                
                // 添加简单的过渡动画
                Behavior on color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    IconText {
                        text: NoticeService.doNotDisturb ? "notifications_off" : "notifications_none"
                        size: 20
                        color: NoticeService.doNotDisturb ? "#1e1e2e" : "#cdd6f4"

                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NoticeService.doNotDisturb = !NoticeService.doNotDisturb
                }
            }

            Rectangle {

                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 14
                color: NoticeService.historyModel.count ? "#f38ba8" : "#45475a"
                
                Behavior on color { ColorAnimation { duration: 200 } }

            
                IconText {
                    anchors.centerIn: parent
                    text: "delete_sweep"
                    size: 20
                    color: NoticeService.historyModel.count? "#1e1e2e" : "#cdd6f4"

                }
                

                MouseArea {
                    id: clearArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NoticeService.clearAll()
                }
            }
        }

        Item{
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            Column {
                anchors.centerIn:parent
                visible: NoticeService.historyModel.count === 0
                spacing: 12
                opacity: visible ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 300 } }

                IconText {
                    text: NoticeService.doNotDisturb ? "notifications_off" : "notifications_none"
                    size: 48
                    color: "#585b70"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "No New Notifications"
                    color: "#585b70"
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // --- 通知列表区域 ---
        ScrollView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ScrollBar.vertical.policy:ScrollBar.AsNeeded
            ColumnLayout{
                width: parent.width
                Layout.fillHeight:true
                Layout.fillWidth:true
                spacing: 12


                Repeater{
                    model:NoticeService.historyModel

                    delegate:Rectangle{
                        property var n: NoticeService.getWrapper(model.seq)

                        Layout.fillWidth:true
                        Layout.preferredHeight: contentCol.implicitHeight + 12

                        visible:n!==null
                        opacity:1
                        color:"transparent"

                        ColumnLayout{
                            id:contentCol
                            anchors.fill:parent
                            anchors.margins:6
                            spacing:3

                            RowLayout{
                                Layout.fillWidth:true

                                Text{
                                    text:n.summary
                                    Layout.fillWidth:true
                                    color:"#cdd6f4"
                                    font.bold:true
                                    font.pixelSize:13
                                    elide:Text.ElideRight                
                                }

                                Text{
                                    text:n.timeStr
                                    color:"#a6adc8"
                                    font.pixelSize:11
                                }

                                MouseArea{
                                    width:16;height:16;
                                    cursorShape:Qt.PointingHandCursor

                                    Text{
                                        anchors.centerIn:parent
                                        text:"x"
                                        color:parent.containsMouse ? "#f38ba8" : "#6c7086"
                                    }
                                    onClicked: NoticeService.removeSeq(n.seq)
                                }
                            }
                            Text{
                                visible:text !== ""
                                text:n.body
                                Layout.fillWidth:true
                                color:"#cdd6f4"
                                font.pixelSize:12
                                wrapMode:Text.WordWrap
                                maximumLineCount:10
                                elide:Text.ElideRight
                            }
                            Image {
                                visible: n.image && n.image !== n.appIcon
                                Layout.fillWidth: true
                                Layout.preferredHeight: 100
                                source: visible ? n.image : ""
                                fillMode: Image.PreserveAspectCrop
                                layer.enabled: true
                            }
                        }
                    }
                }
            }
        }
    }
}