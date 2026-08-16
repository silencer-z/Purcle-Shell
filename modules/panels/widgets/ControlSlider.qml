import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import qs.components
import qs.services

PanelWidget {
    id: root

    color: Theme.surface0
    height: 40
    radius: 20
    ColumnLayout{
        anchors.fill:parent
        anchors.margins:10
        RowLayout {

            anchors.margins: 4
            spacing: 8

            // Volume icon
            MaterialSymbol {
                id: volumeIcon
                text: {
                    if (!AudioService.sink || !AudioService.sink.audio) return "volume_off";
                    if (AudioService.muted || AudioService.volume <= 0) return "volume_off";
                    if (AudioService.volume >= 0.5) return "volume_up";
                    return "volume_down";
                }
                size: 25
                color: Theme.blue
                Layout.alignment: Qt.AlignVCenter
            }

            StyledSlider {
                id: volumeSlider
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                value: AudioService.volume
                configuration: StyledSlider.Configuration.S
                highlightColor: Theme.blue
                trackColor: Theme.surface1
                handleColor: Theme.blue
                dotColor: Theme.overlay0
                dotColorHighlighted: Theme.blue

                property bool userUpdating:false

                onValueChanged: {
                    if (pressed && AudioService.sink?.audio) {
                        AudioService.setVolume(value);
                    }
                }

                onPressedChanged: {
                    userUpdating = pressed;
                    if (pressed && AudioService.sink?.audio) {
                        AudioService.setVolume(value);
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    propagateComposedEvents: true

                    onWheel: wheel => {
                        if (!AudioService.sink?.audio) return;

                        const delta = wheel.angleDelta.y / 120;
                        const newVol = AudioService.volume + delta * 0.02;
                        AudioService.setVolume(newVol);
                        volumeSlider.value = newVol;
                        wheel.accepted = true;
                    }
                }

                Connections {
                    target: AudioService.sink ? AudioService.sink.audio : null
                    function onVolumesChanged() {
                        if (!volumeSlider.pressed && !volumeSlider.userUpdating) {
                            const systemVolume = AudioService.volume;
                            if (Math.abs(volumeSlider.value - systemVolume) > 0.005) {
                                volumeSlider.value = systemVolume;
                            }
                        }
                    }
                }

            }
        }

        RowLayout {
            anchors.margins: 5
            spacing: 8

            // Brightness icon
            MaterialSymbol {
                id: brightnessIcon
                text: {
                    const focusedMonitor = Brightness.getMonitorForScreen(Quickshell.screens[0]);
                    return focusedMonitor?.iconName ?? "brightness_6";
                }
                size: 25
                color: Theme.yellow
                Layout.alignment: Qt.AlignVCenter
            }

            // Brightness slider using StyledSlider
            StyledSlider {
                id: brightnessSlider
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                value: {
                    const focusedMonitor = Brightness.getMonitorForScreen(Quickshell.screens[0]);
                    return focusedMonitor?.brightness ?? 0.5;
                }
                configuration: StyledSlider.Configuration.S
                highlightColor: Theme.yellow
                trackColor: Theme.surface1
                handleColor: Theme.yellow
                dotColor: Theme.overlay0
                dotColorHighlighted: Theme.yellow

                property bool userUpdating:false

                onValueChanged: {
                    if (pressed && !root.userUpdating) {
                        const focusedMonitor = Brightness.getMonitorForScreen(Quickshell.screens[0]);
                        if (focusedMonitor) {
                            focusedMonitor.setBrightness(value);
                        }
                    }
                }

                // Handle direct clicks on the slider track
                onPressedChanged: {
                    userUpdating = pressed;
                    if (pressed) {
                        const focusedMonitor = Brightness.getMonitorForScreen(Quickshell.screens[0]);
                        if (focusedMonitor) {
                            focusedMonitor.setBrightness(value);
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    propagateComposedEvents: true

                    onWheel: wheel => {
                        const focusedMonitor = Brightness.getMonitorForScreen(Quickshell.screens[0]);
                        if (focusedMonitor) {
                            const delta = wheel.angleDelta.y / 120;
                            const currentBrightness = focusedMonitor.brightness;
                            const newBrightness = Math.max(0.01, Math.min(1, currentBrightness - delta * 0.05));
                            focusedMonitor.setBrightness(newBrightness);
                        }
                        wheel.accepted = true;
                    }
                }

                Connections {
                    target: Brightness
                    function onBrightnessChanged() {
                        const focusedMonitor = Brightness.getMonitorForScreen(Quickshell.screens[0]);
                        if (focusedMonitor && !brightnessSlider.pressed && !root.userUpdating) {
                            const systemBrightness = focusedMonitor.brightness;
                            if (Math.abs(brightnessSlider.value - systemBrightness) > 0.005) {
                                brightnessSlider.value = systemBrightness;
                            }
                        }
                    }
                }
            }
        }
    }
}