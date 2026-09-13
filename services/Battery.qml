pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick
import qs.Configs

Singleton {
    id: root

    property bool available: UPower.displayDevice.isLaptopBattery
    property var chargeState: UPower.displayDevice.state
    property bool isCharging: chargeState == UPowerDeviceState.Charging
    property bool isPluggedIn: isCharging || chargeState == UPowerDeviceState.PendingCharge
    property real percentage: UPower.displayDevice?.percentage ?? 1

    readonly property real lowThreshold: Config.battery.low
    readonly property real criticalThreshold: Config.battery.critical
    readonly property real suspendThreshold: Config.battery.suspend
    readonly property bool allowAutomaticSuspend: Config.battery.autoSuspend

    property bool isLow: available && (percentage <= lowThreshold)
    property bool isCritical: available && (percentage <= criticalThreshold)
    property bool isSuspending: available && (percentage <= suspendThreshold)
    property bool isFull: available && (percentage >= 0.98)

    property bool isLowAndNotCharging: isLow && !isCharging
    property bool isCriticalAndNotCharging: isCritical && !isCharging
    property bool isSuspendingAndNotCharging: allowAutomaticSuspend && isSuspending && !isCharging
    property bool isFullAndCharging: isFull && isCharging

    property real energyRate: UPower.displayDevice.changeRate
    property real timeToEmpty: UPower.displayDevice.timeToEmpty
    property real timeToFull: UPower.displayDevice.timeToFull

    function iconName(): string {
        if (!available)
            return "power";
        if (isCharging || isPluggedIn) {
            if (percentage >= 0.90)
                return "battery_charging_full";
            if (percentage >= 0.80)
                return "battery_charging_90";
            if (percentage >= 0.60)
                return "battery_charging_80";
            if (percentage >= 0.50)
                return "battery_charging_60";
            if (percentage >= 0.30)
                return "battery_charging_50";
            if (percentage >= 0.20)
                return "battery_charging_30";
            return "battery_charging_20";
        }
        if (percentage >= 0.95)
            return "battery_full";
        if (percentage >= 0.85)
            return "battery_6_bar";
        if (percentage >= 0.70)
            return "battery_5_bar";
        if (percentage >= 0.55)
            return "battery_4_bar";
        if (percentage >= 0.40)
            return "battery_3_bar";
        if (percentage >= 0.25)
            return "battery_2_bar";
        return "battery_1_bar";
    }

    readonly property real health: {
        const devList = UPower.devices.values;
        for (let i = 0; i < devList.length; ++i) {
            const dev = devList[i];
            if (dev.isLaptopBattery && dev.healthSupported) {
                const h = dev.healthPercentage;
                if (h === 0)
                    return 0.01;
                if (h < 1)
                    return h * 100;
                return h;
            }
        }
        return 0;
    }

    // notify-send 走 org.freedesktop.Notifications，由本 shell 的 NotificationServer 接收
    function notify(summary: string, body: string, urgency: string): void {
        const args = ["notify-send", summary, body, "-a", "PurcleShell", "--hint=int:transient:1"];
        if (urgency)
            args.push("-u", urgency);
        Quickshell.execDetached(args);
    }

    onIsLowAndNotChargingChanged: {
        if (!root.available || !isLowAndNotCharging)
            return;
        root.notify(qsTr("电量低"), qsTr("建议接入电源"), "critical");
    }

    onIsCriticalAndNotChargingChanged: {
        if (!root.available || !isCriticalAndNotCharging)
            return;
        root.notify(qsTr("电量严重不足"), qsTr("请立即充电"), "critical");
    }

    onIsSuspendingAndNotChargingChanged: {
        if (root.available && isSuspendingAndNotCharging)
            Quickshell.execDetached(["systemctl", "suspend"]);
    }

    onIsFullAndChargingChanged: {
        if (!root.available || !isFullAndCharging)
            return;
        root.notify(qsTr("电量已满"), qsTr("可以拔掉充电器"), "");
    }
}
