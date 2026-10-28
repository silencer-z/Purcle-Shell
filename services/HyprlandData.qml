pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

// Hyprland 客户端/工作区数据（Task View 预览用，参考 dots HyprlandData）
Singleton {
    id: root

    readonly property int defaultWorkspaceCount: 5

    property var windowList: []
    property var windowByAddress: ({})
    property var workspaces: []
    property var workspaceIds: []
    property var workspaceById: ({})
    property var specialWorkspaces: []
    property var activeWorkspace: null
    property var monitors: []

    function isValidWorkspace(ws: var): bool {
        if (!ws || ws.id === undefined)
            return false;
        if (ws.id < 0)
            return true;
        return ws.id >= 1 && ws.id <= 100;
    }

    function specialDispatch(ws: var): string {
        const name = ws?.name ?? "special";
        return `hl.dsp.focus({ workspace = "${name}" })`;
    }

    function specialLabel(ws: var): string {
        const name = ws?.name ?? "special";
        if (name.startsWith("special:"))
            return name.slice("special:".length) || "special";
        return name;
    }

    function isWorkspaceOccupied(workspaceId: int, ws: var): bool {
        if (ws?.windows > 0)
            return true;
        return root.windowList.some(win => win.workspace?.id === workspaceId);
    }

    function toplevelsForWorkspace(workspaceId: int): var {
        return ToplevelManager.toplevels.values.filter(toplevel => {
            const address = `0x${toplevel.HyprlandToplevel?.address}`;
            const win = root.windowByAddress[address];
            return win?.workspace?.id === workspaceId;
        });
    }

    function clientsForWorkspace(workspaceId: int): var {
        return root.windowList.filter(win => win.workspace?.id === workspaceId);
    }

    function clientForToplevel(toplevel: var): var {
        if (!toplevel?.HyprlandToplevel)
            return null;
        const address = `0x${toplevel.HyprlandToplevel.address}`;
        return root.windowByAddress[address];
    }

    function monitorForWorkspace(workspaceId: int): var {
        const ws = root.workspaceById[workspaceId];
        if (!ws)
            return root.monitors[0] ?? null;
        return root.monitors.find(m => m.id === ws.monitor) ?? root.monitors[0] ?? null;
    }

    function iconForClient(client: var, toplevel: var): string {
        const key = toplevel?.appId || client?.class || client?.initialClass || "";
        return Quickshell.iconPath(key, "default.svg");
    }

    function primaryMonitor(): var {
        const active = root.activeWorkspace?.monitorID;
        if (active !== undefined) {
            const match = root.monitors.find(m => m.id === active);
            if (match)
                return match;
        }
        return root.monitors[0] ?? null;
    }

    // 常规 1..N（至少 5 个）；有窗口的特殊工作区占第一个空位，无窗口则不显示
    function workspaceEntries(): var {
        const regularIds = root.workspaceIds.slice().sort((a, b) => a - b);
        const activeId = root.activeWorkspace?.id ?? 1;
        const positiveActive = activeId > 0 ? activeId : 0;
        const maxRegular = Math.max(
            root.defaultWorkspaceCount,
            regularIds.length ? Math.max(...regularIds) : 1,
            positiveActive
        );

        const result = [];
        for (let i = 1; i <= maxRegular; i++) {
            const ws = root.workspaceById[i];
            result.push({
                id: i,
                label: String(i),
                dispatch: `hl.dsp.focus({ workspace = ${i} })`,
                isSpecial: false,
                occupied: regularIds.includes(i) && root.isWorkspaceOccupied(i, ws)
            });
        }

        const occupiedSpecials = [];
        for (const ws of root.specialWorkspaces) {
            if (!root.isWorkspaceOccupied(ws.id, ws))
                continue;
            occupiedSpecials.push({
                id: ws.id,
                label: root.specialLabel(ws),
                dispatch: root.specialDispatch(ws),
                isSpecial: true,
                occupied: true
            });
        }

        for (const sp of occupiedSpecials) {
            const emptyIdx = result.findIndex(e => !e.isSpecial && !e.occupied);
            if (emptyIdx >= 0)
                result[emptyIdx] = sp;
            else
                result.push(sp);
        }

        return result;
    }

    function indexOfWorkspace(workspaceId: int): int {
        const entries = root.workspaceEntries();
        return entries.findIndex(e => e.id === workspaceId);
    }

    function updateWindows(): void {
        clientsProc.running = true;
    }

    function updateWorkspaces(): void {
        workspacesProc.running = true;
        activeWsProc.running = true;
    }

    function updateMonitors(): void {
        monitorsProc.running = true;
    }

    function updateAll(): void {
        root.updateWindows();
        root.updateWorkspaces();
        root.updateMonitors();
    }

    Component.onCompleted: root.updateAll()

    Connections {
        target: Hyprland

        function onRawEvent(event): void {
            if (["openlayer", "closelayer", "screencast"].includes(event.name))
                return;
            root.updateAll();
        }
    }

    Process {
        id: clientsProc

        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const list = JSON.parse(text);
                    root.windowList = list;
                    const byAddr = {};
                    for (const win of list)
                        byAddr[win.address] = win;
                    root.windowByAddress = byAddr;
                } catch (e) {
                    console.warn("[HyprlandData] 解析 clients 失败", e);
                }
            }
        }
    }

    Process {
        id: workspacesProc

        command: ["hyprctl", "workspaces", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const raw = JSON.parse(text).filter(ws => root.isValidWorkspace(ws));
                    root.workspaces = raw;
                    const byId = {};
                    for (const ws of raw)
                        byId[ws.id] = ws;
                    root.workspaceById = byId;
                    root.workspaceIds = raw.filter(ws => ws.id > 0).map(ws => ws.id);
                    root.specialWorkspaces = raw.filter(ws => ws.id < 0);
                } catch (e) {
                    console.warn("[HyprlandData] 解析 workspaces 失败", e);
                }
            }
        }
    }

    Process {
        id: activeWsProc

        command: ["hyprctl", "activeworkspace", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.activeWorkspace = JSON.parse(text);
                } catch (e) {
                    console.warn("[HyprlandData] 解析 activeworkspace 失败", e);
                }
            }
        }
    }

    Process {
        id: monitorsProc

        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.monitors = JSON.parse(text);
                } catch (e) {
                    console.warn("[HyprlandData] 解析 monitors 失败", e);
                }
            }
        }
    }
}
