pragma Singleton

import QtQml
import Quickshell
import Quickshell.Io

// Hyprland 焦点与工作区状态：quickshell 在 Hyprland 0.56 下读不到这些状态（初始查询返回垃圾值、
// focusedWorkspace 不更新），这里直接订阅事件 socket（事件驱动，不轮询）+ 启动查询。
Singleton {
    id: root

    // 聚焦工作区 id（特殊工作区为 -99）
    property int focusedWorkspaceId: -1
    property string focusedMonitorName: ""
    // 已存在的工作区 id
    property var workspaceIds: []

    function refresh(): void {
        workspaceProc.running = true;
        focusProc.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: focusProc

        command: ["hyprctl", "-j", "activeworkspace"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const info = JSON.parse(text);
                    root.focusedWorkspaceId = info.id;
                    root.focusedMonitorName = info.monitor;
                } catch (e) {
                    console.log("HyprlandState: 解析 activeworkspace 失败", e);
                }
            }
        }
    }

    Process {
        id: workspaceProc

        command: ["hyprctl", "-j", "workspaces"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.workspaceIds = JSON.parse(text).map(w => w.id).filter(id => id >= 0);
                } catch (e) {
                    console.log("HyprlandState: 解析 workspaces 失败", e);
                }
            }
        }
    }

    Socket {
        id: sock

        path: `${Quickshell.env("XDG_RUNTIME_DIR")}/hypr/${Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")}/.socket2.sock`
        connected: true

        parser: SplitParser {
            onRead: line => {
                const [event, data] = line.split(">>");
                if (event === "workspace") {
                    const id = parseInt(data);
                    root.focusedWorkspaceId = isNaN(id) ? -99 : id;
                } else if (event === "focusedmon") {
                    const [monitor, workspace] = data.split(",");
                    const id = parseInt(workspace);
                    if (!isNaN(id))
                        root.focusedWorkspaceId = id;
                    root.focusedMonitorName = monitor;
                } else if (event.startsWith("createworkspace") || event.startsWith("destroyworkspace") || event.startsWith("moveworkspace") || event.startsWith("renameworkspace")) {
                    workspaceProc.running = true;
                }
            }
        }
    }

    // 断线重连
    Timer {
        interval: 1000
        repeat: true
        running: !sock.connected
        onTriggered: {
            sock.connected = true;
            root.refresh();
        }
    }
}
