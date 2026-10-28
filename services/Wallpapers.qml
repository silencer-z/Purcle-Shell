pragma Singleton
pragma ComponentBehavior: Bound

import Qt.labs.folderlistmodel
import QtQuick
import Quickshell
import Quickshell.Io

import qs.Configs

// 壁纸服务：列出目录壁纸、搜索过滤、应用/随机切换。
// 着色开启时按当前 Theme 色盘生成缓存图再交给 awww；wallpaper.txt 始终记原图路径。
Singleton {
    id: root

    readonly property string currentWallpaper: Paths.currentWallpaper
    readonly property string currentWallpaperName: {
        const p = root.currentWallpaper;
        return p ? p.split('/').pop() : "";
    }
    readonly property string currentWallpaperFile: Paths.currentWallpaperFile
    readonly property bool recolor: Config.wallpaper.recolor
    readonly property string recolorScript: Paths.shellDir + "/assets/scripts/recolor-wallpaper.py"
    readonly property string recolorOutput: Paths.cacheDir + "/PurcleShell/recolored/current.png"

    readonly property string paletteSig: {
        return [
            Theme.base, Theme.mantle, Theme.crust,
            Theme.surface0, Theme.surface1, Theme.surface2,
            Theme.text, Theme.overlay0,
            Theme.mauve, Theme.blue, Theme.sky, Theme.green, Theme.teal,
            Theme.yellow, Theme.peach, Theme.red, Theme.pink, Theme.lavender
        ].map(c => root.toHex(c)).join("");
    }

    property var wallpaperList: []
    property string lastSetPath: ""
    property string _recolorSrc: ""
    property bool _pendingRestart: false

    function matching(query: string) {
        if (!query)
            return root.wallpaperList;
        const q = query.toLowerCase();
        return root.wallpaperList.filter(path => {
            const fileName = path.split('/').pop().toLowerCase();
            return fileName.includes(q);
        });
    }

    function toHex(c): string {
        const r = Math.round(c.r * 255).toString(16).padStart(2, "0");
        const g = Math.round(c.g * 255).toString(16).padStart(2, "0");
        const b = Math.round(c.b * 255).toString(16).padStart(2, "0");
        return `#${r}${g}${b}`;
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

    function setWallpaper(path: string): void {
        if (!path)
            return;

        root.lastSetPath = path;
        Quickshell.execDetached({
            command: ["sh", "-c", `printf '%s' ${JSON.stringify(path)} > ${JSON.stringify(root.currentWallpaperFile)}`]
        });
        root.applyDisplay(path, false);
    }

    function applyDisplay(path: string, debounce: bool): void {
        if (!path)
            return;
        if (!root.recolor) {
            root._pendingRestart = false;
            if (recolorProc.running)
                recolorProc.running = false;
            root.awwwImg(path);
            return;
        }
        root._recolorSrc = path;
        if (debounce)
            recolorTimer.restart();
        else
            root.startRecolor(path);
    }

    function startRecolor(path: string): void {
        if (!path)
            return;
        const cmd = ["python3", root.recolorScript, path, root.recolorOutput];
        const hexes = root.paletteHexes();
        for (let i = 0; i < hexes.length; i++)
            cmd.push(hexes[i]);
        recolorProc.command = cmd;
        root._recolorSrc = path;
        if (recolorProc.running) {
            root._pendingRestart = true;
            recolorProc.running = false;
            return;
        }
        recolorProc.running = true;
    }

    function paletteHexes(): var {
        if (Theme.scheme === "matugen") {
            const extracted = Color.recolorHexes;
            if (extracted && extracted.length >= 4)
                return extracted;
        }
        return [
            Theme.crust, Theme.mantle, Theme.base, Theme.surface0, Theme.surface1,
            Theme.text, Theme.overlay0,
            Theme.mauve, Theme.blue, Theme.sky, Theme.green, Theme.teal,
            Theme.yellow, Theme.peach, Theme.red, Theme.pink, Theme.lavender
        ].map(c => root.toHex(c));
    }

    function awwwImg(path: string): void {
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

    onCurrentWallpaperChanged: {
        if (!root.currentWallpaper || root.currentWallpaper === root.lastSetPath)
            return;
        // 着色开启时，启动/外部改 wallpaper.txt 也要把原图套色；关闭时不要重复 awww 以免闪屏
        if (root.recolor)
            root.applyDisplay(root.currentWallpaper, false);
    }

    onRecolorChanged: {
        if (root.currentWallpaper)
            root.applyDisplay(root.currentWallpaper, false);
    }

    onPaletteSigChanged: {
        if (root.recolor && root.currentWallpaper)
            root.applyDisplay(root.currentWallpaper, true);
    }

    Timer {
        id: recolorTimer

        interval: 400
        repeat: false
        onTriggered: root.startRecolor(root._recolorSrc)
    }

    Process {
        id: recolorProc

        stderr: SplitParser {
            onRead: line => console.warn("[recolor]", line)
        }

        onExited: code => {
            if (root._pendingRestart) {
                root._pendingRestart = false;
                recolorProc.running = true;
                return;
            }
            if (!root.recolor)
                return;
            if (code === 0)
                root.awwwImg(root.recolorOutput);
            else {
                console.warn("[wallpaper] 着色失败，回退原图");
                root.awwwImg(root._recolorSrc);
            }
        }
    }
}
