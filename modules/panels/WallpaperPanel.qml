import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

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

    implicitWidth: 800
    implicitHeight: 500

    PathView {
        id: wallpaperPath

        Layout.fillWidth: true
        Layout.fillHeight: true

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
            Qt.callLater(() => {
                const idx = ServiceWallpaper.wallpaperList.indexOf(ServicePath.currentWallpaper);
                currentIndex = idx !== -1 ? idx : 0;
            });
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
                NAnim {
                    duration: Config.appearance.animations.durations.normal
                    easing.bezierCurve: Config.appearance.animations.curves.expressiveDefaultSpatial
                }
            }

            Behavior on opacity {
                NAnim {
                    duration: Config.appearance.animations.durations.normal
                    easing.bezierCurve: Config.appearance.animations.curves.expressiveDefaultSpatial
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
                    NAnim {
                        duration: Config.appearance.animations.durations.normal
                        easing.bezierCurve: Config.appearance.animations.curves.expressiveDefaultSpatial
                    }
                }
                Behavior on implicitHeight {
                    NAnim {
                        duration: Config.appearance.animations.durations.normal
                        easing.bezierCurve: Config.appearance.animations.curves.expressiveDefaultSpatial
                    }
                }
                Behavior on radius {
                    NAnim {
                        duration: Config.appearance.animations.durations.normal
                        easing.bezierCurve: Config.appearance.animations.curves.expressiveDefaultSpatial
                    }
                }

                Image {
                    anchors.fill: parent
                    source: "file://" + delegateItem.modelData
                    sourceSize: Qt.size(200, 200)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true

                    Elevation {
                        anchors.fill: parent
                        z: -1
                        level: 3
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: cardRect.radius
                    color: Qt.rgba(0, 0, 0, delegateItem.isCurrent ? 0.0 : 0.22)

                    Behavior on color {
                        CAnim {
                            duration: Config.appearance.animations.durations.normal
                        }
                    }
                }

                MArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (!delegateItem.isCurrent) {
                            wallpaperPath.currentIndex = delegateItem.index;
                        } else {
                            Quickshell.execDetached({
                                command: ["shell", "ipc", "call", "img", "set", delegateItem.modelData]
                            });
                        }
                    }
                }
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                Quickshell.execDetached({
                    command: ["shell", "ipc", "call", "img", "set", WallpaperFileModels.filteredWallpaperList[currentIndex]]
                });
                event.accepted = true;
            }
            if (event.key === Qt.Key_Escape) {
                GlobalStates.isWallpaperSwitcherOpen = false;
                event.accepted = true;
            }
            if (event.key === Qt.Key_Tab) {
                searchField.forceActiveFocus();
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