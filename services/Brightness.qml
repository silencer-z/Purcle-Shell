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
    readonly property list<BrightnessMonitor> monitors: Quickshell.screens.map(screen => monitorComp.createObject(root, {
        screen
    }))

    // 跟随 Hyprland 聚焦屏幕的亮度控制器（UI 统一用它，不重复查找）
    readonly property var focusedMonitor: {
        const name = Hyprland.focusedMonitor?.name;
        return name !== undefined ? (monitors.find(m => m.screen.name === name) ?? null) : null;
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

        command: ["ddcutil", "detect", "--brief"]
        stdout: SplitParser {
            splitMarker: "\n\n"
            onRead: data => {
                if (data.startsWith("Display ")) {
                    const lines = data.split("\n").map(l => l.trim());
                    root.ddcMonitors.push({
                        model: lines.find(l => l.startsWith("Monitor:")).split(":")[2],
                        busNum: lines.find(l => l.startsWith("I2C bus:")).split("/dev/i2c-")[1]
                    });
                }
            }
        }
        onExited: root.ddcMonitorsChanged()
    }

    Process {
        id: setProc
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
            if (brightness >= 0.8) {
                "brightness_7";
            } else if (brightness >= 0.4) {
                "brightness_6";
            } else {
                "brightness_4";
            }
        }

        property var doAfterRefresh: function() {monitor.brightness = monitor.realValue;monitor.ready = true;}

        onBrightnessChanged: {
            if (monitor.ready) {
                root.brightnessChanged();
            }
        }

        readonly property Process freshProc: Process {
            command: isDdc ? ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"] : ["sh", "-c", `echo "a b c $(brightnessctl g) $(brightnessctl m)"`]
            stdout: SplitParser {
                onRead: data => {
                    const [, , , current, max] = data.split(" ");
                    monitor.realValue = parseInt(current) / parseInt(max);
                    monitor.doAfterRefresh()
                    monitor.doAfterRefresh=function() {monitor.brightness = monitor.realValue;monitor.ready = true;}
                }
            }
        }

        function setBrightness(value: real): void {
            value = Math.max(0.01, Math.min(1, value));
            const rounded = Math.round(value * 100);
            if (Math.round(brightness * 100) === rounded)
                return;
            brightness = value
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

    // IpcHandler {
    //     target: "brightness"

    //     function increment() {
    //         onPressed: root.increaseBrightness()
    //     }

    //     function decrement() {
    //         onPressed: root.decreaseBrightness()
    //     }
    // }

    // GlobalShortcut {
    //     name: "brightnessIncrease"
    //     description: qsTr("Increase brightness")
    //     onPressed: root.increaseBrightness()
    // }

    // GlobalShortcut {
    //     name: "brightnessDecrease"
    //     description: qsTr("Decrease brightness")
    //     onPressed: root.decreaseBrightness()
    // }
}
