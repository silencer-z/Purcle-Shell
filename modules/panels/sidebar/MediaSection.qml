pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Configs
import qs.components
import qs.services

// 紧凑 MPRIS 行（参考 dots bar/Media：单行 + 小封面，非 sidebar 内嵌大卡片）
PanelWidget {
    id: root

    visible: Player.hasPlayer
    color: Theme.surface0

    Behavior on color {
        ColorAnim {}
    }

    implicitHeight: visible ? content.implicitHeight + Config.appearance.padding.normal * 2 : 0

    Timer {
        running: Player.isPlaying
        interval: 500
        repeat: true
        onTriggered: Player.refreshPosition()
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: Config.appearance.spacing.smaller

        RowLayout {
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small

            ClippingRectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: Config.appearance.rounding.small
                color: Theme.surface1

                Image {
                    anchors.fill: parent
                    source: Player.trackArtUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: Player.trackArtUrl !== ""
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    visible: Player.trackArtUrl === ""
                    text: Player.isPlaying ? "pause" : "music_note"
                    size: Config.appearance.fonts.size.medium
                    color: Theme.mauve
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                StyledText {
                    Layout.fillWidth: true
                    text: Player.trackTitle
                    color: Theme.text
                    font.pixelSize: Config.appearance.fonts.size.medium
                    font.bold: true
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Player.trackArtist
                    color: Theme.overlay0
                    font.pixelSize: Config.appearance.fonts.size.tiny
                    elide: Text.ElideRight
                }
            }

            RowLayout {
                spacing: 2

                MediaButton {
                    icon: "skip_previous"
                    enabled: Player.canGoPrevious
                    onClicked: Player.previous()
                }

                MediaButton {
                    icon: Player.isPlaying ? "pause" : "play_arrow"
                    enabled: Player.canTogglePlaying
                    accent: true
                    onClicked: Player.togglePlay()
                }

                MediaButton {
                    icon: "skip_next"
                    enabled: Player.canGoNext
                    onClicked: Player.next()
                }
            }
        }

        StyledProgressBar {
            Layout.fillWidth: true
            visible: Player.length > 0
            value: Player.progress
            valueBarHeight: 3
            highlightColor: Theme.mauve
            trackColor: Theme.surface1
            sperm: Player.isPlaying
            showEndCap: false
            enableValueAnimation: true
        }
    }

    component MediaButton: Rectangle {
        id: btn

        required property string icon
        property bool enabled: true
        property bool accent: false

        signal clicked()

        implicitWidth: accent ? 32 : 28
        implicitHeight: accent ? 32 : 28
        radius: accent ? implicitWidth / 2 : Config.appearance.rounding.small / 2
        color: !enabled
            ? "transparent"
            : btnArea.containsMouse
              ? (accent ? Qt.darker(Theme.mauve, 1.08) : Theme.surface1)
              : (accent ? Theme.mauve : "transparent")

        MaterialSymbol {
            anchors.centerIn: parent
            text: btn.icon
            size: accent ? Config.appearance.fonts.size.medium : Config.appearance.fonts.size.small
            color: accent ? Theme.onPrimary : (btn.enabled ? Theme.subtext1 : Theme.overlay0)
        }

        MouseArea {
            id: btnArea

            anchors.fill: parent
            hoverEnabled: true
            enabled: btn.enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: btn.clicked()
        }
    }
}
