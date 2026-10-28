pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Configs
import qs.services

// 单工作区预览卡（参考 dots TaskViewWorkspace）
Item {
    id: root

    required property var entry
    required property bool previewLive
    property int cardWidth: 420
    property int previewHeight: 252

    readonly property int workspaceId: entry.id
    readonly property bool isActive: HyprlandData.activeWorkspace?.id === root.workspaceId
    readonly property var monitor: HyprlandData.monitorForWorkspace(root.workspaceId)
    readonly property real windowScale: previewHeight / Math.max(1, monitor?.height ?? 1080)
    readonly property int iconSize: Math.max(22, Math.round(root.cardWidth * 0.065))
    readonly property int iconPad: Math.max(3, Math.round(iconSize * 0.15))

    implicitWidth: root.cardWidth
    implicitHeight: previewBox.height

    Item {
        id: previewBox

        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: root.previewHeight

        ClippingRectangle {
            id: preview

            anchors.fill: parent
            radius: Config.appearance.rounding.small
            color: Theme.surface1

            Image {
                anchors.fill: parent
                source: Paths.currentWallpaper ? ("file://" + Paths.currentWallpaper) : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: source !== ""
                opacity: entry.occupied ? 1 : 0.35
            }

            Repeater {
                model: HyprlandData.toplevelsForWorkspace(root.workspaceId)

                delegate: Item {
                    id: winItem

                    required property var modelData

                    readonly property var client: HyprlandData.clientForToplevel(modelData)
                    readonly property string iconSource: HyprlandData.iconForClient(client, modelData)

                    visible: client !== null
                    x: (client?.at?.[0] ?? 0) * root.windowScale
                    y: (client?.at?.[1] ?? 0) * root.windowScale
                    width: (client?.size?.[0] ?? 0) * root.windowScale
                    height: (client?.size?.[1] ?? 0) * root.windowScale

                    ScreencopyView {
                        anchors.fill: parent
                        captureSource: root.previewLive ? winItem.modelData : null
                        live: root.previewLive
                    }

                    Rectangle {
                        visible: winItem.width > iconSize + 8 && winItem.height > iconSize + 8
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 4
                        width: root.iconSize + root.iconPad * 2
                        height: root.iconSize + root.iconPad * 2
                        radius: Config.appearance.rounding.small / 2
                        color: Theme.base
                        border.width: 1
                        border.color: Theme.surface2

                        Image {
                            anchors.centerIn: parent
                            width: root.iconSize
                            height: root.iconSize
                            source: winItem.iconSource
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                        }
                    }
                }
            }

            Rectangle {
                visible: entry.isSpecial
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 6
                radius: Config.appearance.rounding.small / 2
                color: Theme.mauve
                implicitWidth: specialLabel.implicitWidth + 8
                implicitHeight: specialLabel.implicitHeight + 4

                Text {
                    id: specialLabel

                    anchors.centerIn: parent
                    text: entry.label
                    color: Theme.onPrimary
                    font.pixelSize: Config.appearance.fonts.size.tiny
                    font.bold: true
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: Config.appearance.rounding.small
            color: "transparent"
            border.width: root.isActive ? 2 : 1
            border.color: root.isActive ? Theme.mauve : (entry.occupied ? Theme.surface2 : Theme.overlay0)
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Hyprland.dispatch(root.entry.dispatch);
            Visibilities.task = false;
        }
    }
}
