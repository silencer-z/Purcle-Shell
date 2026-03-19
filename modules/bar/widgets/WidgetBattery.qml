import QtQuick
import Quickshell.Services.UPower

import qs.services

BarWidget{
    id:root

    property alias widthBattery: batteryBody.implicitWidth
    property alias heightBattery: batteryBody.implicitHeight

    readonly property bool batCharging: UPower.displayDevice.state == UPowerDeviceState.Charging
    readonly property real batPercentage: UPower.displayDevice.percentage
    readonly property real batFill: batteryBody.width * (batPercentage / 100.0)

    property real chargeFillIndex: 0

    implicitWidth: widthBattery
    implicitHeight: heightBattery

    onBatChargingChanged: {
        if (root.batCharging)
            root.chargeFillIndex = root.batPercentage * 100;
    }

    Rectangle {
        id: batteryBody

        implicitWidth: 26
        implicitHeight: 12
        clip: true
        color: "transparent"
        radius: Appearance.rounding.small * 0.5

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        border {
            width: 2
            color: root.batPercentage <= 0.2 && !root.batCharging ? Colours.m3Colors.m3Error : Qt.alpha(Colours.m3Colors.m3Outline, 0.5)
        }

        StyledRect {
            id: batteryFill

            anchors {
                left: parent.left
                leftMargin: 2
                top: parent.top
                topMargin: 2
                bottom: parent.bottom
                bottomMargin: 2
            }
            implicitWidth: root.batCharging ? (parent.width - 4) * (root.chargeFillIndex / 100.0) : (parent.width - 4) * root.batPercentage
            color: {
                if (root.batCharging)
                    return Colours.m3Colors.m3Green;
                if (root.batPercentage <= 0.2)
                    return Colours.m3Colors.m3Red;
                if (root.batPercentage <= 0.5)
                    return Colours.m3Colors.m3Yellow;
                return Colours.m3Colors.m3OnSurface;
            }
            radius: parent.radius - 2

            Behavior on implicitWidth {
                enabled: !root.batCharging
                NAnim {}
            }
        }

        StyledText {
            anchors.centerIn: parent
            text: Math.round(root.batPercentage * 100)
            font {
                pixelSize: batteryBody.height * 0.65
                weight: Font.Bold
            }
            color: root.batPercentage <= 0.5 ? Colours.m3Colors.m3OnBackground : Colours.m3Colors.m3Surface
        }
    }
}