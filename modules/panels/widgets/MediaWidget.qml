import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell

import qs.components
import qs.services

PanelWidget {
    id: root
    height: 200
    radius: 20
    color: "#313244"

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.radius
        }
    }

    // === 当前曲目信息 ===
    property string artUrl: MprisService.trackArtUrl
    property url displayArt: artUrl.length > 0
        ? artUrl
        : Qt.resolvedUrl(Quickshell.shellPath("assets/apps/zenbrowser.svg"))

    // === 小按钮组件 ===
    component TrackChangeButton: Rectangle {
        implicitWidth: 28
        implicitHeight: 28
        radius: 14
        property string iconName
        signal clicked()
        color: ma.hovered ? "#E0D6F0" : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }

        MaterialSymbol {
            anchors.centerIn: parent
            size: 22
            fill: 1
            horizontalAlignment: Text.AlignHCenter
            color: "#49454F"
            text: iconName
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    // === 主内容区 ===
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 15

        // 封面图
        Rectangle {
            id: artBackground
            Layout.fillHeight: true
            implicitWidth: height
            radius: 8
            color: "#F3EDF7"

            Image {
                anchors.fill: parent
                source: root.displayArt
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        // 信息 + 控制
        ColumnLayout {
            Layout.fillHeight: true
            spacing: 2

            StyledText {
                id: trackTitle
                Layout.fillWidth: true
                font.pixelSize: 18
                color: "#cdd6f4"
                elide: Text.ElideRight
                text: MprisService.trackTitle
            }

            StyledText {
                id: trackArtist
                Layout.fillWidth: true
                font.pixelSize: 13
                color: "#bac2de"
                elide: Text.ElideRight
                text: MprisService.trackArtist
            }

            Item { Layout.fillHeight: true }

            // 底部控制区
            RowLayout {
                id: controlsRow
                Layout.fillWidth: true
                spacing: 10

                TrackChangeButton {
                    iconName: "skip_previous"
                    enabled: MprisService.canGoPrevious ?? false
                    opacity: enabled ? 1.0 : 0.4
                    onClicked: MprisService.previous()
                }

                // 播放 / 暂停按钮
                Rectangle {
                    id: playPauseButton
                    width: 44
                    height: 44
                    radius: 22

                    property bool isPlaying: MprisService.isPlaying ?? false
                    property bool hovered: ma.hovered ?? false

                    color: isPlaying
                        ? (hovered ? "#705AAB" : "#6750A4")
                        : (hovered ? "#E0D6F0" : "#E8DEF8")

                    MaterialSymbol {
                        anchors.centerIn: parent
                        size: 24
                        color: playPauseButton.isPlaying ? "#FFFFFF" : "#49454F"
                        text: playPauseButton.isPlaying ? "pause" : "play_arrow"
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.togglePlay()
                    }
                }

                TrackChangeButton {
                    iconName: "skip_next"
                    enabled: MprisService.canGoNext ?? false
                    opacity: enabled ? 1.0 : 0.4
                    onClicked: MprisService.next()
                }
            }
        }
    }

    // === 监听曲目变化 ===
    Connections {
        target: MprisService
        function onTrackChanged(player) {
            console.log(`[MprisWidget] Track changed -> ${player.trackArtist} - ${player.trackTitle}`)
        }
    }
}
