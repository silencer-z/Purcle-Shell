import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services

Item {
    id: root
    required property var panelWrapper
    property int currentIndex: 0

    readonly property int maxPanelHeight: 800
    readonly property int headerHeight: 80  // 标题栏高度
    readonly property int itemHeight: 66    // 每个列表项的高度(60+6间距)

    implicitWidth: 600
    implicitHeight: Math.max(600,Math.min(maxPanelHeight, headerHeight + (ClipModel.itemModel?.count || 0) * itemHeight))

    function close() {
        currentIndex = 0
        if (panelWrapper) panelWrapper.close()
    }

    function init() {
        ClipModel.refresh()
        list.forceActiveFocus()
        currentIndex = 0
    }


    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#1e1e2e"


        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            /* ===== 标题栏 ===== */
            RowLayout {
                spacing: 12
                Layout.fillWidth: true

                Rectangle {
                    width: 40; height: 40
                    radius: 12
                    color: "#313244"
                    Text {
                        anchors.centerIn: parent
                        text: "📋"
                        font.pixelSize: 20
                    }
                }

                Text {
                    text: "Clipboard History"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#cdd6f4"
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true } // 占位符

                // 清空按钮示例
                Rectangle {
                    width: 80; height: 30
                    radius: 8
                    color: "#f38ba8"
                    opacity: clearMouse.containsMouse ? 1.0 : 0.8

                    Text {
                        anchors.centerIn: parent
                        text: "Clear All"
                        color: "#11111b"
                        font.bold: true
                    }
                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        onClicked: {
                            Quickshell.execDetached(["cliphist", "wipe"])
                            ClipModel.refresh()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#313244"
            }

            /* ===== 列表内容 ===== */
            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true

                model: ClipModel.itemModel
                currentIndex: root.currentIndex
                clip: true
                spacing: 6

                // 优化滚动条行为
                boundsBehavior: Flickable.StopAtBounds

                // 键盘导航逻辑
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        root.close()
                    } else if (event.key === Qt.Key_Up) {
                        decrementCurrentIndex()
                    } else if (event.key === Qt.Key_Down) {
                        incrementCurrentIndex()
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        ClipModel.copy(model.get(currentIndex))
                        root.close()
                    } else if (event.key === Qt.Key_Delete) {
                        ClipModel.deleteItem(model.get(currentIndex))
                    }
                }

                delegate: Rectangle {
                    width: list.width
                    height: 60
                    radius: 8
                    color: ListView.isCurrentItem ? "#313244" : "transparent"

                    // 鼠标悬停交互
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: list.currentIndex = index
                        onClicked: {
                            ClipModel.copy(model)
                            root.close()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        // 1. 图标/类型指示器
                        Rectangle {
                            width: 40; height: 40
                            radius: 8
                            color: "#45475a"

                            Text {
                                anchors.centerIn: parent
                                font.pixelSize: 18
                                text: {
                                    switch(model.type) {
                                        case "image": return "🖼️";
                                        case "file": return "📁";
                                        default: return "📝";
                                    }
                                }
                            }
                        }

                        // 2. 内容预览
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            color: "transparent"

                            // 文本/文件路径显示
                            Text {
                                visible: model.type !== "image"
                                anchors.fill: parent
                                anchors.margins: 4
                                text: {
                                    if (model.type === "file") {
                                        return decodeURIComponent(model.preview.replace("file://", ""))
                                    }
                                    return model.preview
                                }
                                color: "#cdd6f4"
                                font.pixelSize: 14
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                                maximumLineCount: 2
                            }

                            // 图片显示
                            Image {
                                visible: model.type === "image" && model.cached
                                source: model.imagePath || ""
                                anchors.fill: parent
                                anchors.margins: 4
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                cache: false
                            }

                            // 图片加载中提示
                            Text {
                                visible: model.type === "image" && !model.cached
                                text: "Loading..."
                                color: "#6c7086"
                                anchors.centerIn: parent
                            }
                        }

                        Text {
                            visible: ListView.isCurrentItem
                            text: "↵ Copy"
                            color: "#a6e3a1"
                            font.pixelSize: 12
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
