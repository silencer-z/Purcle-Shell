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

    property var wallpaperList: []

    function matching(query: string) {
        if (!query)
            return root.wallpaperList;
        const q = query.toLowerCase();
        return root.wallpaperList.filter(path => {
            const fileName = path.split('/').pop().toLowerCase();
            return fileName.includes(q);
        });
    }

    FolderListModel {
        id: wallpaperFolder

        folder: `file://${Paths.wallpaperDir}`
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

    function setRandom(list): void {
        const pool = list ?? root.wallpaperList;
        if (!pool || pool.length === 0)
            return;
        const pick = pool[Math.floor(Math.random() * pool.length)];
        root.setWallpaper(pick);
    }

    function setRelative(delta: int, list): void {
        const pool = list ?? root.wallpaperList;
        if (!pool || pool.length === 0)
            return;
        const idx = pool.indexOf(root.currentWallpaper);
        const next = (idx + delta + pool.length) % pool.length;
        root.setWallpaper(pool[next]);
    }
}
