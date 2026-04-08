pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.services as Service
import qs.components

ListView {
    id: listView

    signal executeApp(var entry)
    signal executeAction(var action)
    signal indexChanged(int index)

    clip: true
    spacing: 2
    model: Service.AppModel.appModel
    currentIndex: 0

    highlight: Rectangle {
        color: "#cba6f7"
        radius: 20
    }

    highlightMoveDuration: 500
    highlightResizeDuration: 0

    onCurrentIndexChanged: indexChanged(currentIndex)

    delegate: Item {
        id: listViewDelegate
        required property var modelData
        required property int index
        property bool selected: index === ListView.view.currentIndex
        width: listView.width
        height: modelData.isHeader?32:60

        property bool showActions: true
        opacity: 0
        x: -20
        Component.onCompleted: {
            entranceAnimation.start();
        }
        ParallelAnimation {
            id: entranceAnimation
            NumberAnimation {
                target: listViewDelegate
                property: "opacity"
                to: 1
                duration: 200
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: listViewDelegate
                property: "x"
                to: 0
                duration: 250
                easing.type: Easing.OutBack
                easing.overshoot: 1.1
            }
        }

        Rectangle {
            anchors.fill: parent
            visible: modelData.isHeader
            color: "transparent"

            // scale: appMouseArea.containsMouse ? 1.02 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            /* 应用名称 */
            StyledText {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                text: modelData.name || "Other"
                font.pixelSize: 15
                antialiasing: true
                color: "#cdd6f4"
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: 8
            color: "transparent"
            visible: !modelData.isHeader

            Rectangle {
                anchors.fill: parent
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins:4
                    spacing: 12

                    Image {
                        source: Quickshell.iconPath(listViewDelegate.modelData.icon, "system-help")
                        sourceSize.width: 42
                        sourceSize.height: 42
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        Behavior on scale {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.2
                            }
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 1

                        StyledText {
                            width: parent.width
                            text: listViewDelegate.modelData.highlightedName
                            font.pixelSize: 16
                            elide: Text.ElideRight
                            textFormat: TextEdit.RichText
                            color:listViewDelegate.selected?"#181825":"#cdd6f4"
                        }

                        StyledText {
                            width: parent.width
                            text: listViewDelegate.modelData.genericName || listViewDelegate.modelData.comment
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            visible: text.length > 0
                            color:listViewDelegate.selected?"#181825":"#cdd6f4"
                            opacity: 0.7
                        }
                    }
                }
            }
        }
    }
}
