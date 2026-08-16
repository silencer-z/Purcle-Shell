import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.Configs
import qs.services

ClippingRectangle {
    id: root

    required property int maxHeight

    radius: Config.appearance.border.rounding
    topLeftRadius: Config.appearance.border.rounding
    topRightRadius: Config.appearance.border.rounding
    bottomLeftRadius: 0
    bottomRightRadius: 0
    color: "transparent"

    readonly property int intrinsicHeight: 340

    function close() {
        Visibilities.wallpaper = false;
    }

    function focusInput() {
        wallpaperPath.forceActiveFocus();
    }

    implicitWidth: 1150
    implicitHeight: Math.min(root.intrinsicHeight, root.maxHeight)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // ==== 标题栏 ====
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            StyledText {
                text: "壁纸选择"
                font.pixelSize: 16
                font.bold: true
                color: Theme.text
            }

            StyledText {
                text: ServiceWallpaper.currentWallpaperName || "未设置"
                font.pixelSize: 13
                color: Theme.overlay0
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.maximumWidth: 300
            }

            Item {
                Layout.fillWidth: true
            }

            // 随机按钮
            Rectangle {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 28
                radius: 8
                color: randomBtn.containsMouse ? Theme.surface1 : Theme.surface0

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    MaterialSymbol {
                        text: "shuffle"
                        size: 16
                        color: Theme.mauve
                    }
                    StyledText {
                        text: "随机"
                        font.pixelSize: 12
                        color: Theme.text
                    }
                }

                MouseArea {
                    id: randomBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ServiceWallpaper.setRandom()
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }

        // ==== 搜索框 ====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            radius: 10
            color: Theme.surface0

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                MaterialSymbol {
                    text: "search"
                    size: 18
                    color: Theme.overlay0
                }

                StyledTextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    color: Theme.text
                    text: ServiceWallpaper.searchQuery
                    onTextChanged: ServiceWallpaper.searchQuery = text
                    Keys.onEscapePressed: {
                        if (searchInput.text) {
                            searchInput.text = "";
                        } else {
                            root.close();
                        }
                    }
                }

                MaterialSymbol {
                    text: ServiceWallpaper.searchQuery ? "close" : ""
                    size: 16
                    color: Theme.overlay0
                    visible: ServiceWallpaper.searchQuery !== ""
                    MouseArea {
                        anchors.fill: parent
                        onClicked: searchInput.text = ""
                    }
                }
            }
        }

        // ==== 壁纸轮播 ====
        PathView {
            id: wallpaperPath

            Layout.fillWidth: true
            Layout.fillHeight: true

            readonly property real unitWidth: width / 5

            model: ScriptModel {
                values: ServiceWallpaper.filteredWallpaperList
            }
            pathItemCount: 3
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            clip: true
            focus: true
            cacheItemCount: 5

            // 当前壁纸居中
            onModelChanged: {
                const idx = model.values.indexOf(ServiceWallpaper.currentWallpaper);
                currentIndex = idx !== -1 ? idx : (model.count > 0 ? 0 : 0);
            }
            Component.onCompleted: {
                function trySetIndex() {
                    if (ServiceWallpaper.wallpaperList.length > 0) {
                        const idx = ServiceWallpaper.wallpaperList.indexOf(ServiceWallpaper.currentWallpaper);
                        currentIndex = idx !== -1 ? idx : 0;
                    } else {
                        Qt.callLater(trySetIndex);
                    }
                }
                trySetIndex();
            }

            path: Path {
                startX: 0
                startY: wallpaperPath.height / 2

                PathLine {
                    x: wallpaperPath.width
                    y: wallpaperPath.height / 2
                }
            }

            delegate: Item {
                id: delegateItem

                required property var modelData
                required property int index

                readonly property bool isCurrent: PathView.isCurrentItem
                readonly property bool isApplied: modelData === ServiceWallpaper.currentWallpaper

                implicitWidth: isCurrent ? wallpaperPath.unitWidth * 3 : wallpaperPath.unitWidth * 2
                implicitHeight: wallpaperPath.height

                z: isCurrent ? 100 : 1
                opacity: isCurrent ? 1.0 : 0.85

                Behavior on implicitWidth {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                Rectangle {
                    id: cardRect
                    anchors.centerIn: parent
                    implicitWidth: parent.width - (delegateItem.isCurrent ? Math.max(20, wallpaperPath.unitWidth * 1) : Math.max(10, wallpaperPath.unitWidth * 0.5))
                    implicitHeight: parent.height
                    scale: delegateItem.isCurrent ? 1 : 0.8
                    clip: true
                    layer.enabled: true
                    radius: 16
                    border.width: delegateItem.isApplied ? 3 : 0
                    border.color: Theme.mauve

                    Image {
                        id: wallpaperImg
                        anchors.fill: parent
                        source: "file://" + delegateItem.modelData
                        sourceSize: Qt.size(300, 300)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    // 应用标记
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 8
                        width: appliedText.width + 12
                        height: 20
                        radius: 10
                        color: Theme.mauve
                        visible: delegateItem.isApplied

                        StyledText {
                            id: appliedText
                            anchors.centerIn: parent
                            text: "使用中"
                            font.pixelSize: 11
                            color: Theme.onPrimary
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!delegateItem.isCurrent) {
                                wallpaperPath.currentIndex = delegateItem.index;
                            } else {
                                ServiceWallpaper.setWallpaper(delegateItem.modelData);
                            }
                        }
                    }

                    Behavior on implicitWidth {
                        NumberAnimation { duration: Config.appearance.animations.durations.normal; easing.type: Easing.OutCubic }
                    }
                    Behavior on implicitHeight {
                        NumberAnimation { duration: Config.appearance.animations.durations.normal; easing.type: Easing.OutCubic }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: Config.appearance.animations.durations.normal; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            root.close();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            wallpaperPath.decrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            wallpaperPath.incrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            const list = ServiceWallpaper.filteredWallpaperList;
            if (wallpaperPath.currentIndex >= 0 && wallpaperPath.currentIndex < list.length)
                ServiceWallpaper.setWallpaper(list[wallpaperPath.currentIndex]);
            event.accepted = true;
        }
    }
}
