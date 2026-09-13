pragma Singleton

import QtQuick
import Quickshell

// 面板可见性状态（互斥：同一时间只开一个面板）
QtObject {
    id: root

    property bool launcher: false
    property bool clipboard: false
    property bool wallpaper: false
    property bool sidebar: false

    // 面板互斥：显式写入
    function togglePanel(name: string): void {
        switch (name) {
        case "launcher":
            root.launcher = !root.launcher;
            root.clipboard = false;
            root.wallpaper = false;
            root.sidebar = false;
            break;
        case "clipboard":
            root.clipboard = !root.clipboard;
            root.launcher = false;
            root.wallpaper = false;
            root.sidebar = false;
            break;
        case "wallpaper":
            root.wallpaper = !root.wallpaper;
            root.launcher = false;
            root.clipboard = false;
            root.sidebar = false;
            break;
        case "sidebar":
            root.sidebar = !root.sidebar;
            root.launcher = false;
            root.clipboard = false;
            root.wallpaper = false;
            break;
        }
    }

    function isOpen(name: string): bool {
        return !!root[name];
    }

    function hideAll(): void {
        root.launcher = false;
        root.clipboard = false;
        root.wallpaper = false;
        root.sidebar = false;
    }
}
