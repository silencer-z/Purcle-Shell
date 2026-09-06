pragma Singleton
pragma ComponentBehavior: Bound

import Qt.labs.folderlistmodel
import QtQuick
import Quickshell

// 壁纸服务：列出目录壁纸、搜索过滤、应用/随机切换（参考 dots-hyprland 的 Wallpapers 组织方式）
Singleton {
    id: root

    readonly property string currentWallpaper: Paths.currentWallpaper
    readonly property string currentWallpaperName: {
        const p = root.currentWallpaper;
        return p ? p.split('/').pop() : "";
    }
    readonly property string currentWallpaperFile: Paths.currentWallpaperFile

    property string searchQuery: ""
    property string debouncedSearchQuery: ""

    property var wallpaperList: []
    property var filteredWallpaperList: {
        if (root.debouncedSearchQuery === "")
            return root.wallpaperList;

        const q = root.debouncedSearchQuery.toLowerCase();
        return root.wallpaperList.filter(path => {
            const fileName = path.split('/').pop().toLowerCase();
            return fileName.includes(q);
        });
    }

    // 搜索防抖
    Timer {
        id: searchDebounce
        interval: 300
        repeat: false
        onTriggered: root.debouncedSearchQuery = root.searchQuery
    }
    onSearchQueryChanged: searchDebounce.restart()

    FolderListModel {
        id: wallpaperFolder

        folder: Qt.resolvedUrl(Paths.wallpaperDir)
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.avif"]
        showDirs: false
        showDotAndDotDot: false
        showHidden: false

        onCountChanged: {
            let list = [];
            for (let i = 0; i < count; i++) {
                list.push(get(i, "filePath"));
            }
            root.wallpaperList = list;
        }
    }

    // ---- 操作 ----

    function setWallpaper(path: string): void {
        if (!path)
            return;

        Quickshell.execDetached({
            command: ["sh", "-c", `printf '%s' ${JSON.stringify(path)} > ${JSON.stringify(root.currentWallpaperFile)}`]
        })
        Quickshell.execDetached({
            command: ["awww", "img", "-o", "", path, "--transition-type", "random"]
        });
    }

    function setRandom(): void {
        const list = root.filteredWallpaperList;
        if (list.length === 0)
            return;
        const pick = list[Math.floor(Math.random() * list.length)];
        root.setWallpaper(pick);
    }

    function setRelative(delta: int): void {
        const list = root.filteredWallpaperList;
        if (list.length === 0)
            return;
        const idx = list.indexOf(root.currentWallpaper);
        const next = (idx + delta + list.length) % list.length;
        root.setWallpaper(list[next]);
    }
}
