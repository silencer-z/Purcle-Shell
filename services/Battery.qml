pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick
import Quickshell.Io

import qs.services

Singleton {
    id: root
    property bool available: UPower.displayDevice.isLaptopBattery
    property var chargeState: UPower.displayDevice.state
    property bool isCharging: chargeState == UPowerDeviceState.Charging
    property bool isPluggedIn: isCharging || chargeState == UPowerDeviceState.PendingCharge
    property real percentage: UPower.displayDevice?.percentage ?? 1
    readonly property bool allowAutomaticSuspend: true
    readonly property bool soundEnabled: false

    property bool isLow: available && (percentage <= 20 / 100)
    property bool isCritical: available && (percentage <= 5 / 100)
    property bool isSuspending: available && (percentage <= 1 / 100)
    property bool isFull: available && (percentage >= 98 / 100)

    property bool isLowAndNotCharging: isLow && !isCharging
    property bool isCriticalAndNotCharging: isCritical && !isCharging
    property bool isSuspendingAndNotCharging: allowAutomaticSuspend && isSuspending && !isCharging
    property bool isFullAndCharging: isFull && isCharging

    property real energyRate: UPower.displayDevice.changeRate
    property real timeToEmpty: UPower.displayDevice.timeToEmpty
    property real timeToFull: UPower.displayDevice.timeToFull

    property real health: (function() {
        const devList = UPower.devices.values;
        for (let i = 0; i < devList.length; ++i) {
            const dev = devList[i];
            if (dev.isLaptopBattery && dev.healthSupported) {
                const health = dev.healthPercentage;
                if (health === 0) {
                    return 0.01;
                } else if (health < 1) {
                    return health * 100;
                } else {
                    return health;
                }
            }
        }
        return 0;
    })()


    onIsLowAndNotChargingChanged: {
        if (!root.available || !isLowAndNotCharging) return;
        Quickshell.execDetached([
            "notify-send", 
            "Low battery", 
            "Consider plugging in your device", 
            "-u", "critical",
            "-a", "Shell",
            "--hint=int:transient:1",
        ])

    }

    onIsCriticalAndNotChargingChanged: {
        if (!root.available || !isCriticalAndNotCharging) return;
        Quickshell.execDetached([
            "notify-send", 
            "Critically low battery", 
            "Please charge!\nAutomatic suspend triggers at 1%", 
            "-u", "critical",
            "-a", "Shell",
            "--hint=int:transient:1",
        ]);

    }

    onIsSuspendingAndNotChargingChanged: {
        if (root.available && isSuspendingAndNotCharging) {
            Quickshell.execDetached(["bash", "-c", `systemctl suspend || loginctl suspend`]);
        }
    }

    onIsFullAndChargingChanged: {
        if (!root.available || !isFullAndCharging) return;
        Quickshell.execDetached([
            "notify-send",
            "Battery full",
            "Please unplug the charger",
            "-a", "Shell",
            "--hint=int:transient:1",
        ]);
    }

    onIsPluggedInChanged: {
        if (!root.available || !root.soundEnabled) return;
        if (isPluggedIn) {
            Quickshell.execDetached([
                "notify-send",
                "Battery starts charging",
                "Charger plugged in, charging started.",
                "-a", "Shell",
                "--hint=int:transient:1",
            ]);
        } else {
            Quickshell.execDetached([
                "notify-send",
                "Battery Stop charging",
                "Charger removed.",
                "-a", "Shell",
                "--hint=int:transient:1",
            ]);
        }
    }
}