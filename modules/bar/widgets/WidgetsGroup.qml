import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components
import qs.services

BarWidget {
    id: root

    required property var monitor

    color: "transparent"
    widgetColor: "#313244"
    widgetRadius: 8

    RowLayout {
        id: rawlayout

        spacing: 5

        Item {
            width: 3
        }

        IconText {
            id: volumeIcon

            property bool hovered: audioHoverHandler.hovered

            font.pixelSize: 22
            text: {
                if (!AudioService.sink || !AudioService.sink.audio)
                    return "volume_off";

                if (AudioService.sink.audio.mute) {
                    return "volume_off";
                } else if (AudioService.sink.audio.volume > 0.66) {
                    return "volume_up";
                } else if (AudioService.sink.audio.volume > 0.33) {
                    return "volume_down";
                    up;
                } else if (AudioService.sink.audio.volume > 0) {
                    return "volume_mute";
                } else {
                    return "volume_off";
                }
            }

            StyledTooltip {
                content: "音量: " + (
                    AudioService.sink && AudioService.sink.audio ? Math.round(AudioService.sink.audio.volume * 100) + "%": "0%"
                )
            }

            HoverHandler {
                id: audioHoverHandler
            }

            MouseArea {
                anchors.fill: parent
                onWheel: (wheel) => {
                    if (!AudioService.sink || !AudioService.sink.audio) {
                        return ;
                    }
                    const volumeStep = 0.01;
                    let currentVolume = AudioService.sink.audio.volume;
                    if (wheel.angleDelta.y > 0)
                        AudioService.sink.audio.volume = Math.min(currentVolume + volumeStep, 1);
                    else if (wheel.angleDelta.y < 0)
                        AudioService.sink.audio.volume = Math.max(currentVolume - volumeStep, 0);
                }
            }

        }

        IconText {
            id: brightnessIcon

            property bool hovered: brightnessHoverHandler.hovered

            text: monitor.iconName
            font.pixelSize: 22

            StyledTooltip {
                content: "亮度: " + Math.round(monitor.brightness * 100) + "%"
            }

            HoverHandler {
                id: brightnessHoverHandler
            }

            MouseArea {
                anchors.fill: parent
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0)
                        Brightness.increaseBrightness();
                    else if (wheel.angleDelta.y < 0)
                        Brightness.decreaseBrightness();
                }
            }

        }

        IconText {
            id: netIcon

            text: Network.materialSymbol
            font.pixelSize: 22
        }

        IconText {
            id: blueToothIcon

            text: Bluetooth.getIcon()
            font.pixelSize: 22
            visible: Bluetooth.available
        }

        Item {
            width: 3
        }
    }
}