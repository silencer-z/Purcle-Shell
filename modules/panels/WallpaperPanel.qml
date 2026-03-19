import QtQuick
import Quickshell
import Quickshell.Widgets

import qs.components
import qs.Configs
import qs.services

Item{
    required property var panelWrapper
    function close() {
        console.log("wallpaper selector close");
    }

    function init() {
        console.log("wallpaper selector init");
    }

    implicitWidth: 950
    implicitHeight: 300

    function setWallpaper(path:string):void{
        Quickshell.execDetached({
            command: ["sh", "-c", `printf '%s' ${JSON.stringify(path)} > ${JSON.stringify(ServicePath.currentWallpaperFile)}`]
        })
        Quickshell.execDetached({
            command: ["swww", "img", "-o", "", path,"--transition-type","random"]
        });
    }

    PathView {
        id: wallpaperPath

        anchors.fill:parent
        anchors.topMargin:30
        anchors.bottomMargin:30
        anchors.leftMargin:0
        anchors.rightMargin:0

        readonly property real unitWidth: width / (Config.wallpaper.visibleWallpaper + 1)

        model: ScriptModel {
            values: ServiceWallpaper.filteredWallpaperList
        }
        pathItemCount: Config.wallpaper.visibleWallpaper
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        clip: true
        cacheItemCount: Config.wallpaper.visibleWallpaper + 2

        Component.onCompleted: {
            forceActiveFocus()
            function trySetIndex() {
                if (ServiceWallpaper.wallpaperList.length > 0) {
                    const idx = ServiceWallpaper.wallpaperList.indexOf(ServicePath.currentWallpaper);
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

            // Center card = 2 units wide, side cards = 1 unit wide
            implicitWidth: isCurrent ? wallpaperPath.unitWidth * 2 : wallpaperPath.unitWidth
            implicitHeight: wallpaperPath.height

            z: isCurrent ? 100 : 1
            opacity: isCurrent ? 1.0 : 0.92

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: Config.appearance.animations.durations.normal;
                    easing.type: Easing.OutCubic 
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Config.appearance.animations.durations.normal;
                    easing.type: Easing.OutCubic 
                }
            }

            ClippingRectangle {
                id: cardRect

                anchors.centerIn: parent
                // Gap between cards scales with unit width so it looks proportional at any count
                implicitWidth: parent.width - (delegateItem.isCurrent ? Math.max(20, wallpaperPath.unitWidth * 0.3) : Math.max(12, wallpaperPath.unitWidth * 0.2))
                implicitHeight: parent.height

                radius: delegateItem.isCurrent ? Config.appearance.rounding.large : 20

                color: "transparent"

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: Config.appearance.animations.durations.normal;
                        easing.type: Easing.OutCubic 
                    }
                }
                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: Config.appearance.animations.durations.normal;
                        easing.type: Easing.OutCubic 
                    }
                }
                Behavior on radius {
                    NumberAnimation {
                        duration: Config.appearance.animations.durations.normal;
                        easing.type: Easing.OutCubic 
                    }
                }

                Image {
                    anchors.fill: parent
                    source: "file://" + delegateItem.modelData
                    sourceSize: Qt.size(200, 200)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                }

                Rectangle {
                    anchors.fill: parent
                    radius: cardRect.radius
                    color: Qt.rgba(0, 0, 0, delegateItem.isCurrent ? 0.0 : 0.22)

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.appearance.animations.durations.normal
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (!delegateItem.isCurrent) {
                            wallpaperPath.currentIndex = delegateItem.index;
                        } else {
                            setWallpaper(delegateItem.modelData)
                        }
                    }
                }
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                setWallpaper(ServiceWallpaper.filteredWallpaperList[currentIndex])
                event.accepted = true;
            }
            if (event.key === Qt.Key_Escape) {
                panelWrapper.close();
                event.accepted = true;
            }

            if (event.key === Qt.Key_Left) {
                decrementCurrentIndex();
                event.accepted = true;
            }
            if (event.key === Qt.Key_Right) {
                incrementCurrentIndex();
                event.accepted = true;
            }
        }
    }
}