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

    function batteryIconName(): string {
        if (!Battery.available)
            return "power";
        if (Battery.isCharging || Battery.isPluggedIn) {
            if (Battery.percentage >= 0.90) return "battery_charging_full";
            if (Battery.percentage >= 0.80) return "battery_charging_90";
            if (Battery.percentage >= 0.60) return "battery_charging_80";
            if (Battery.percentage >= 0.50) return "battery_charging_60";
            if (Battery.percentage >= 0.30) return "battery_charging_50";
            if (Battery.percentage >= 0.20) return "battery_charging_30";
            return "battery_charging_20";
        }
        if (Battery.percentage >= 0.95) return "battery_full";
        if (Battery.percentage >= 0.85) return "battery_6_bar";
        if (Battery.percentage >= 0.70) return "battery_5_bar";
        if (Battery.percentage >= 0.55) return "battery_4_bar";
        if (Battery.percentage >= 0.40) return "battery_3_bar";
        if (Battery.percentage >= 0.25) return "battery_2_bar";
        return "battery_1_bar";
    }

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
                if (!AudioService.sink || !AudioService.sink.audio)
                    return "volume_off";
                if (AudioService.muted || AudioService.volume <= 0)
                    return "volume_off";
                if (AudioService.volume >= 0.5)
                    return "volume_up";
                return "volume_down";
            }

            StyledTooltip {
                content: "音量: " + AudioService.volumePercent + "%"
            }

            HoverHandler {
                id: audioHoverHandler
            }

            MouseArea {
                anchors.fill: parent
                onWheel: (wheel) => {
                    if (!AudioService.sink || !AudioService.sink.audio)
                        return;
                    const step = wheel.angleDelta.y > 0 ? 0.02 : -0.02;
                    AudioService.setVolume(AudioService.volume + step);
                }
            }

        }

        MaterialSymbol {
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
        }

        MaterialSymbol {
            id: blueToothIcon

            text: Bluetooth.getIcon()
            font.pixelSize: 22
            visible: Bluetooth.available
        }

        MaterialSymbol {
            id: batteryIcon

            visible: Battery.available
            property bool hovered: batteryHoverHandler.hovered

            text: root.batteryIconName()
            font.pixelSize: 22

            StyledTooltip {
                content: "电量: " + Math.round(Battery.percentage * 100) + "%"
            }

            HoverHandler {
                id: batteryHoverHandler
            }
        }

        Item {
            width: 3
        }
    }
}
