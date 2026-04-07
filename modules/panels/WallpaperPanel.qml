import QtQuick
import Quickshell

import qs.components
import qs.Configs
import qs.services

Item{
    id:root

    required property var panelWrapper

    function close() {
        console.log("wallpaper selector close");
    }

    function init() {
        wallpaperPath.forceActiveFocus();
    }

    implicitWidth: 1150
    implicitHeight: 300

    function setWallpaper(path:string):void{
        Quickshell.execDetached({
            command: ["sh", "-c", `printf '%s' ${JSON.stringify(path)} > ${JSON.stringify(ServicePath.currentWallpaperFile)}`]
        })
        Quickshell.execDetached({
            command: ["awww", "img", "-o", "", path,"--transition-type","random"]
        });
    }

    PathView {
        id: wallpaperPath

        anchors.fill:parent
        anchors.topMargin:30
        anchors.bottomMargin:30
        anchors.leftMargin:0
        anchors.rightMargin:0

        readonly property real unitWidth: width / 5

        model: ScriptModel {
            values: ServiceWallpaper.filteredWallpaperList
        }
        pathItemCount: 3
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        clip:true
        focus:true
        cacheItemCount: 5

        Component.onCompleted: {
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

            implicitWidth: isCurrent ? wallpaperPath.unitWidth * 3 : wallpaperPath.unitWidth*2
            implicitHeight: wallpaperPath.height

            z: isCurrent ? 100 : 1
            opacity: isCurrent ? 1.0 : 0.85

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 150;
                    easing.type: Easing.OutCubic 
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150;
                    easing.type: Easing.OutCubic 
                }
            }


            Rectangle {
                id: cardRect;
                anchors.centerIn: parent;
                implicitWidth: parent.width - (delegateItem.isCurrent ? Math.max(20, wallpaperPath.unitWidth * 1) : Math.max(10, wallpaperPath.unitWidth * 0.5))
                implicitHeight: parent.height;
                scale:delegateItem.isCurrent?1:0.8
                clip:true;
                layer.enabled:true;
                radius: delegateItem.isCurrent ? 20 : 20;

                Image {
                    id:wallpaperImg
                    anchors.fill: parent
                    source: "file://" + delegateItem.modelData
                    sourceSize: Qt.size(200, 200)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
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
                Behavior on scale {
                    NumberAnimation {
                        duration: Config.appearance.animations.durations.normal;
                        easing.type: Easing.OutCubic 
                    }
                }
            }
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            panelWrapper.close();
            event.accepted = true;
        }else if (event.key === Qt.Key_Left) {
            wallpaperPath.decrementCurrentIndex();
            event.accepted = true;
        }else if (event.key === Qt.Key_Right) {
            wallpaperPath.incrementCurrentIndex();
            event.accepted = true;
        }else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            setWallpaper(ServiceWallpaper.filteredWallpaperList[wallpaperPath.currentIndex])
            event.accepted = true;
        }
    }
}