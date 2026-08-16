pragma Singleton

import QtQuick
import Quickshell

QtObject {
    id: root

    property bool launcher: false
    property bool clipboard: false
    property bool wallpaper: false
    property bool dashboard: false

    // 每次只允许一个面板显示（互斥），避免多个面板同时出现
    function togglePanel(name: string): void {
        const valid = name === "launcher" || name === "clipboard" || name === "wallpaper" || name === "dashboard";
        if (!valid)
            return;

        const currently = root[name];
        root.launcher = false;
        root.clipboard = false;
        root.wallpaper = false;
        root.dashboard = false;
        root[name] = !currently;
    }

    function hideAll(): void {
        root.launcher = false;
        root.clipboard = false;
        root.wallpaper = false;
        root.dashboard = false;
    }
}
