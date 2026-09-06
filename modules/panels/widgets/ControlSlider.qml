pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Configs
import qs.components
import qs.services

// dashboard 音量 + 亮度控制（跟随当前聚焦屏幕的亮度）
PanelWidget {
    id: root

    color: Theme.surface0
    implicitHeight: 100
    radius: Config.appearance.rounding.normal

    readonly property var focusedMonitor: {
        const fm = Hyprland.focusedMonitor;
        const name = fm ? fm.name : "";
        return Brightness.monitors.find(m => m.screen.name === name) ?? Brightness.monitors[0] ?? null;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Config.appearance.padding.normal
        spacing: Config.appearance.spacing.small

        // ==== 音量 ====
        RowLayout {
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small

            MaterialSymbol {
                text: Audio.muted || Audio.volume <= 0 ? "volume_off" : Audio.volume >= 0.5 ? "volume_up" : "volume_down"
                size: 20
                color: Theme.blue

                TapHandler {
                    onTapped: Audio.toggleMute()
                }
            }

            StyledSlider {
                id: volumeSlider

                Layout.fillWidth: true
                Layout.preferredHeight: 20
                value: Audio.volume
                configuration: StyledSlider.Configuration.S
                highlightColor: Theme.blue
                trackColor: Theme.surface1
                handleColor: Theme.blue
                dotColor: Theme.overlay0
                dotColorHighlighted: Theme.blue

                onValueChanged: {
                    if (pressed)
                        Audio.setVolume(value);
                }

                onMoved: Audio.setVolume(value)

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    propagateComposedEvents: true

                    onWheel: wheel => {
                        Audio.setVolume(Audio.volume + (wheel.angleDelta.y > 0 ? 0.02 : -0.02));
                        wheel.accepted = true;
                    }
                }
            }

            StyledText {
                Layout.preferredWidth: 36
                text: Audio.volumePercent + "%"
                color: Theme.subtext1
                font.pixelSize: 12

                horizontalAlignment: Text.AlignRight
            }
        }

        // ==== 亮度 ====
        RowLayout {
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small

            MaterialSymbol {
                text: root.focusedMonitor?.iconName ?? "brightness_6"
                size: 20
                color: Theme.yellow
            }

            StyledSlider {
                id: brightnessSlider

                Layout.fillWidth: true
                Layout.preferredHeight: 20
                value: root.focusedMonitor?.brightness ?? 0.5
                enabled: root.focusedMonitor !== null
                configuration: StyledSlider.Configuration.S
                highlightColor: Theme.yellow
                trackColor: Theme.surface1
                handleColor: Theme.yellow
                dotColor: Theme.overlay0
                dotColorHighlighted: Theme.yellow

                onValueChanged: {
                    if (pressed && root.focusedMonitor)
                        root.focusedMonitor.setBrightness(Math.max(0.01, Math.min(1, value)));
                }

                onMoved: {
                    if (root.focusedMonitor)
                        root.focusedMonitor.setBrightness(Math.max(0.01, Math.min(1, value)));
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    propagateComposedEvents: true

                    onWheel: wheel => {
                        if (!root.focusedMonitor)
                            return;
                        const b = root.focusedMonitor.brightness + (wheel.angleDelta.y > 0 ? 0.05 : -0.05);
                        root.focusedMonitor.setBrightness(Math.max(0.01, Math.min(1, b)));
                        wheel.accepted = true;
                    }
                }
            }

            StyledText {
                Layout.preferredWidth: 36
                text: Math.round((root.focusedMonitor?.brightness ?? 0) * 100) + "%"
                color: Theme.subtext1
                font.pixelSize: 12

                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
