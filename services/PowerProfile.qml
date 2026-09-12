pragma Singleton

import QtQml
import Quickshell
import Quickshell.Io

// 电源模式服务：读取/设置 powerprofilesctl。
// UI 只读 PowerProfile.current / 调用 PowerProfile.set()，不直接跑进程。
Singleton {
    id: root

    // 当前模式：power-saver / balanced / performance
    property string current: "balanced"
    property bool available: false

    function refresh(): void {
        queryProc.running = true;
    }

    function set(profile: string): void {
        setProc.command = ["powerprofilesctl", "set", profile];
        setProc.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: queryProc

        command: ["powerprofilesctl", "get"]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim();
                if (value !== "") {
                    root.current = value;
                    root.available = true;
                }
            }
        }
    }

    Process {
        id: setProc

        command: []
        onExited: root.refresh()
    }
}
