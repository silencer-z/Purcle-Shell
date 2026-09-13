pragma Singleton
pragma ComponentBehavior: Bound

// From https://github.com/caelestia-dots/shell/ (`quickshell` branch) with modifications.
// License: GPLv3

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

/**
 * For managing brightness of monitors. Supports both brightnessctl and ddcutil.
 */
Singleton {
    id: root

    signal brightnessChanged()

    property var ddcMonitors: []

    // 屏幕增删时同步 monitor 实例：复用已有、销毁移除的（避免 binding 内
    // createObject 泄漏旧对象）；Screens 变化通过整体重新赋值触发通知。
    property var monitors: []

    function updateMonitors(): void {
        const next = [];
        for (const screen of Quickshell.screens) {
            let monitor = root.monitors.find(m => m.screen === screen);
            if (!monitor)
                monitor = monitorComp.createObject(root, {
                    screen
                });
            next.push(monitor);
        }
        for (const monitor of root.monitors) {
            if (next.indexOf(monitor) === -1)
                monitor.destroy();
        }
        root.monitors = next;
    }

    Component.onCompleted: root.updateMonitors()

    Connections {
        target: Quickshell

        function onScreensChanged(): void {
            root.updateMonitors();
        }
    }

    // 跟随聚焦屏幕的亮度控制器（quickshell 焦点状态在 0.56 下不可靠，优先用 HyprlandState）
    readonly property var focusedMonitor: {
        const name = HyprlandState.focusedMonitorName || Hyprland.focusedMonitor?.name;
        return monitors.find(m => m.screen.name === name) ?? monitors[0] ?? null;
    }

    function getMonitorForScreen(screen: ShellScreen): var {
        return monitors.find(m => m.screen === screen);
    }

    function increaseBrightness(): void {
        if (root.focusedMonitor)
            root.focusedMonitor.setBrightness(root.focusedMonitor.brightness + 0.05);
    }

    function decreaseBrightness(): void {
        if (root.focusedMonitor)
            root.focusedMonitor.setBrightness(root.focusedMonitor.brightness - 0.05);
    }

    reloadableId: "brightness"

    onMonitorsChanged: {
        ddcMonitors = [];
        ddcProc.running = true;
    }

    Process {
        id: ddcProc

        // 先攒进本地 buffer，结束时整体重新赋值给 ddcMonitors：
        // var 属性 push 不发通知，手动调用 Changed 信号不可靠
        property var detected: []

        command: ["ddcutil", "detect", "--brief"]
        stdout: SplitParser {
            splitMarker: "\n\n"
            onRead: data => {
                if (!data.startsWith("Display "))
                    return;
                const lines = data.split("\n").map(l => l.trim());
                const monitorLine = lines.find(l => l.startsWith("Monitor:"));
                const busLine = lines.find(l => l.startsWith("I2C bus:"));
                if (!monitorLine || !busLine)
                    return;
                const modelParts = monitorLine.split(":");
                const busParts = busLine.split("/dev/i2c-");
                if (modelParts.length < 3 || busParts.length < 2)
                    return;
                ddcProc.detected.push({
                    model: modelParts[2],
                    busNum: busParts[1]
                });
            }
        }
        onExited: {
            root.ddcMonitors = ddcProc.detected;
            ddcProc.detected = [];
        }
    }

    component BrightnessMonitor: QtObject {
        id: monitor

        required property ShellScreen screen
        readonly property bool isDdc: root.ddcMonitors.some(m => m.model === screen.model)
        readonly property string busNum: root.ddcMonitors.find(m => m.model === screen.model)?.busNum ?? ""
        property real brightness
        property real realValue
        property bool ready: false

        readonly property string iconName: {
            if (brightness >= 0.8)
                return "brightness_7";
            if (brightness >= 0.4)
                return "brightness_6";
            return "brightness_4";
        }

        function applyRefreshed(): void {
            monitor.brightness = monitor.realValue;
            monitor.ready = true;
        }

        onBrightnessChanged: {
            if (monitor.ready) {
                root.brightnessChanged();
            }
        }

        readonly property Process freshProc: Process {
            command: isDdc ? ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"] : ["sh", "-c", `echo "a b c $(brightnessctl g) $(brightnessctl m)"`]
            stdout: SplitParser {
                onRead: data => {
                    const parts = data.trim().split(" ");
                    if (parts.length < 5)
                        return;
                    const current = parseInt(parts[3], 10);
                    const max = parseInt(parts[4], 10);
                    if (!max || isNaN(current) || isNaN(max))
                        return;
                    monitor.realValue = current / max;
                    monitor.applyRefreshed();
                }
            }
        }

        readonly property Process setProc: Process {}

        function setBrightness(value: real): void {
            value = Math.max(0.01, Math.min(1, value));
            const rounded = Math.round(value * 100);
            if (Math.round(brightness * 100) === rounded)
                return;
            brightness = value;
            setProc.command = isDdc ? ["ddcutil", "-b", busNum, "setvcp", "10", rounded] : ["brightnessctl", "s", `${rounded}%`, "--quiet"];
            setProc.startDetached();
        }



        Component.onCompleted: {
            monitor.ready = false;
            freshProc.running = true;
        }

        onBusNumChanged: {
            monitor.ready = false;
            freshProc.running = true;
        }
    }

    Component {
        id: monitorComp

        BrightnessMonitor {}
    }
}
