import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components
import qs.services

BarWidget {
    id: root

    required property var monitor

    color: "transparent"
    widgetColor: Theme.surface0
    widgetRadius: 8

    RowLayout {
        id: rawlayout
        spacing: 5

        Item {
            width: 3
        }

        MaterialSymbol {
            id: volumeIcon
            property bool hovered: audioHoverHandler.hovered
            font.pixelSize: 22
            text: {
                if (!Audio.sink || !Audio.sink.audio)
                    return "volume_off";
                if (Audio.muted || Audio.volume <= 0)
                    return "volume_off";
                if (Audio.volume >= 0.5)
                    return "volume_up";
                return "volume_down";
            }

            StyledTooltip {
                content: "音量: " + Audio.volumePercent + "%"
            }

            HoverHandler {
                id: audioHoverHandler
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Visibilities.togglePanel("sidebar")
                onWheel: (wheel) => {
                    if (!Audio.sink || !Audio.sink.audio)
                        return;
                    const step = wheel.angleDelta.y > 0 ? 0.02 : -0.02;
                    Audio.setVolume(Audio.volume + step);
                }
            }

        }

        MaterialSymbol {
            id: brightnessIcon

            property bool hovered: brightnessHoverHandler.hovered

            text: monitor?.iconName ?? "brightness_6"
            font.pixelSize: 22

            StyledTooltip {
                content: "亮度: " + Math.round((monitor?.brightness ?? 0) * 100) + "%"
            }

            HoverHandler {
                id: brightnessHoverHandler
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Visibilities.togglePanel("sidebar")
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0)
                        Brightness.increaseBrightness();
                    else if (wheel.angleDelta.y < 0)
                        Brightness.decreaseBrightness();
                }
            }

        }

        MaterialSymbol {
            id: netIcon
            property bool hovered: networkHoverHandler.hovered
            text: Network.materialSymbol
            font.pixelSize: 22
            StyledTooltip {
                content: ""+Network.networkName + ":"+ Network.networkStrength + "%"
            }
            HoverHandler {
                id: networkHoverHandler
            }
            MouseArea {
                anchors.fill: parent
                onClicked: Visibilities.togglePanel("sidebar")
            }
        }

        MaterialSymbol {
            id: blueToothIcon

            property bool hovered: blueToothHoverHandler.hovered

            text: Bluetooth.getIcon()
            font.pixelSize: 22
            visible: Bluetooth.available

            StyledTooltip {
                content: "蓝牙"
            }
            HoverHandler {
                id: blueToothHoverHandler
            }
            MouseArea {
                anchors.fill: parent
                onClicked: Visibilities.togglePanel("sidebar")
            }
        }

        MaterialSymbol {
            id: batteryIcon

            visible: Battery.available
            property bool hovered: batteryHoverHandler.hovered

            text: Battery.iconName()
            font.pixelSize: 22

            StyledTooltip {
                content: "电量: " + Math.round(Battery.percentage * 100) + "%"
            }

            HoverHandler {
                id: batteryHoverHandler
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Visibilities.togglePanel("sidebar")
            }
        }

        Item {
            width: 3
        }
    }
}
