import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell
import qs.services
import qs.components

Item {
    id: root
    required property var panelWrapper
    property int currentIndex: 0
    property string searchText: ""

    readonly property int maxPanelHeight: 800
    readonly property int headerHeight: 80
    readonly property int searchHeight: 60
    readonly property int itemHeight: 60

    implicitWidth: 600
    implicitHeight: {
        const totalCount = filterModel.count
        const baseHeight = headerHeight + searchHeight + totalCount * itemHeight + 24
        return Math.min(maxPanelHeight, baseHeight)
    }

    ListModel { id: filterModel }

    function updateFilter() {
        filterModel.clear()
        const query = searchText.toLowerCase().trim()
        const pinned = []
        const unpinned = []
        for (let i = 0; i < ClipModel.itemModel.count; i++) {
            const item = ClipModel.itemModel.get(i)
            if (item.pinned) {
                pinned.push(item)
            } else if (!query || item.preview.toLowerCase().includes(query)) {
                unpinned.push(item)
            }
        }
        pinned.forEach(item => filterModel.append(item))
        unpinned.forEach(item => filterModel.append(item))
    }

    function close() {
        currentIndex = 0
        searchText = ""
        if (panelWrapper) panelWrapper.close()
    }

    function init() {
        ClipModel.refresh()
        searchText = ""
        updateFilter()
        list.forceActiveFocus()
        currentIndex = 0
    }

    onSearchTextChanged: updateFilter()

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#1e1e2e"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
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
                    text: "Clipboard"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#cdd6f4"
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

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
                            updateFilter()
                        }
                    }
                }
            }

            Rectangle {
                id: searchBar
                Layout.fillWidth: true
                Layout.preferredHeight: searchHeight
                radius: 20
                color: "#313244"
                anchors.margins: 15

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    MaterialSymbol {
                        text: "search"
                        size: 24
                        color: "#cdd6f4"
                    }

                    StyledTextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        focus: true
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        onTextChanged: {
                            searchText = text
                        }
                        Keys.onEscapePressed: {
                            if (searchText) {
                                searchText = ""
                            } else {
                                root.close()
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#313244"
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 100
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds

                model: filterModel

                currentIndex: root.currentIndex

                focus: true

                 Keys.onPressed: (event) => {
                     if (event.key === Qt.Key_Escape) {
                         if (searchText) {
                             searchText = ""
                         } else {
                             root.close()
                         }
                         event.accepted = true
                     } else if (event.key === Qt.Key_Up) {
                         decrementCurrentIndex()
                         event.accepted = true
                     } else if (event.key === Qt.Key_Down) {
                         incrementCurrentIndex()
                         event.accepted = true
                     } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                         const item = model.get(currentIndex)
                         if (item) {
                             ClipModel.copy(item)
                             root.close()
                         }
                         event.accepted = true
                     } else if (event.key === Qt.Key_Delete) {
                         const item = model.get(currentIndex)
                         if (item) {
                             ClipModel.deleteItem(item)
                             updateFilter()
                         }
                         event.accepted = true
                     } else if (event.key === Qt.Key_P || event.key === Qt.Key_p) {
                         const item = model.get(currentIndex)
                         if (item) {
                             ClipModel.togglePin(item.id)
                             ClipModel.refresh()
                             updateFilter()
                         }
                         event.accepted = true
                     }
                 }

                delegate: Item {
                    width: list.width
                    height: itemHeight

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: ListView.isCurrentItem ? "#313244" : (model.pinned ? "#2a2a3c" : "transparent")
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Rectangle {
                            width: 40; height: 40
                            radius: 8
                            color: "#45475a"
                            Layout.alignment: Qt.AlignVCenter

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

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"

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

                            Image {
                                visible: model.type === "image" && model.cached
                                source: model.imagePath || ""
                                anchors.fill: parent
                                anchors.margins: 4
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                cache: false
                            }

                            Text {
                                visible: model.type === "image" && !model.cached
                                text: "Loading..."
                                color: "#6c7086"
                                anchors.centerIn: parent
                            }
                        }

                             Rectangle {
                                 width: 70; height: 28
                                 radius: 6
                                 color: model.pinned ? "#fab387" : "#45475a"
                                 Layout.alignment: Qt.AlignVCenter

                                 MaterialSymbol {
                                     text: model.pinned ? "push_pin" : "push_pin_off"
                                     anchors.centerIn: parent
                                     font.pixelSize: 16
                                     color: model.pinned ? "#11111b" : "#cdd6f4"
                                 }
                                 MouseArea {
                                     anchors.fill: parent
                                     onClicked: {
                                         ClipModel.togglePin(model.id)
                                         ClipModel.refresh()
                                         updateFilter()
                                     }
                                 }
                             }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: list.currentIndex = index
                        onClicked: {
                            ClipModel.copy(model)
                            root.close()
                        }
                    }
                }

                Text {
                    visible: parent.count === 0
                    anchors.centerIn: parent
                    text: searchText ? "No results found" : "No clipboard history"
                    color: "#6c7086"
                    font.pixelSize: 14
                }
            }
        }
    }
}