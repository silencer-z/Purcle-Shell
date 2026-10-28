pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Configs
import qs.components
import qs.services

// 单屏 OSD：居中偏上，音量/亮度各一行。
Item {
    id: root

    required property ShellScreen screen
    required property int barHeight

    readonly property bool active: OSD.isActiveOn(screen.name)
    readonly property var monitor: Brightness.getMonitorForScreen(screen)

    visible: opacity > 0
    opacity: active ? 1 : 0
    z: 200

    anchors.horizontalCenter: parent.horizontalCenter
    y: barHeight + Config.appearance.margin.large

    Behavior on opacity {
        NumberAnim {}
    }

    Item {
        id: card

        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: content.implicitWidth + Config.appearance.padding.normal * 2
        implicitHeight: content.implicitHeight + Config.appearance.padding.normal * 2

        ClippingRectangle {
            anchors.fill: parent
            radius: Config.appearance.rounding.normal
            color: Theme.surface0
        }

        ColumnLayout {
            id: content

            anchors.centerIn: parent
            spacing: Config.appearance.spacing.small

            RowLayout {
                visible: OSD.volumeVisible
                spacing: Config.appearance.spacing.small
                Layout.preferredWidth: osdWidth

                MaterialSymbol {
                    text: {
                        if (!Audio.sink?.audio || Audio.muted || Audio.volume <= 0)
                            return "volume_off";
                        if (Audio.volume >= 0.5)
                            return "volume_up";
                        return "volume_down";
                    }
                    size: Config.appearance.fonts.size.icon
                    color: Theme.mauve
                }

                StyledSlider {
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: Audio.volume
                    highlightColor: Theme.mauve
                    handleColor: Theme.mauve
                    onMoved: Audio.setVolume(value)
                }

                StyledText {
                    text: Audio.muted ? qsTr("静音") : Audio.volumePercent + "%"
                    color: Theme.subtext1
                    font.pixelSize: Config.appearance.fonts.size.small
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }

            RowLayout {
                visible: OSD.brightnessVisible && root.monitor
                spacing: Config.appearance.spacing.small
                Layout.preferredWidth: osdWidth

                MaterialSymbol {
                    text: root.monitor?.iconName ?? "brightness_6"
                    size: Config.appearance.fonts.size.icon
                    color: Theme.blue
                }

                StyledSlider {
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: root.monitor?.brightness ?? 0
                    highlightColor: Theme.blue
                    handleColor: Theme.blue
                    onMoved: {
                        if (root.monitor)
                            root.monitor.setBrightness(value);
                    }
                }

                StyledText {
                    text: Math.round((root.monitor?.brightness ?? 0) * 100) + "%"
                    color: Theme.subtext1
                    font.pixelSize: Config.appearance.fonts.size.small
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    readonly property int osdWidth: 280

    TapHandler {
        onTapped: OSD.hide()
    }
}
