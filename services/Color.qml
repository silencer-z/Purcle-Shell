pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.Configs
import qs.services

// 动态配色提供者：当 Config.colors.scheme 为 "matugen" 或 "pywal" 时，
// Theme 会把本单例作为调色板使用。暴露与 themes/*.qml 预设完全相同的语义属性集。
//
// matugen：壁纸变化时自动运行 matugen 生成 ~/.cache/PurcleShell/matugen-colors.json，
//          FileView 监听该文件热更新（壁纸 → 颜色）。
// pywal：  监听 ~/.cache/wal/colors.json（颜色 → 壁纸，颜色与壁纸均由外部 wal 管理）。
Singleton {
    id: root

    readonly property bool available: Config.colors.scheme === "matugen" ? m3Data !== null : walData !== null
    property bool dark: Config.colors.isDarkMode

    // 当前壁纸（依赖 Paths 的 FileView 版本号以响应变化；同目录单例免 import）
    readonly property string wallpaper: {
        Paths.currentWallpaper; // eslint-disable-line
        return Paths.currentWallpaper;
    }
    onWallpaperChanged: root.regenerate()
    onDarkChanged: root.regenerate()
    Component.onCompleted: root.regenerate()

    // ==== matugen 生成（防抖：等 awww 过渡稳定后再提取） ====
    function regenerate(): void {
        if (Config.colors.scheme !== "matugen" || !root.wallpaper)
            return;
        generateTimer.restart();
    }

    Timer {
        id: generateTimer

        interval: 500
        repeat: false
        onTriggered: {
            matugenProc.command = [
                "matugen",
                "image",
                root.wallpaper,
                "--config",
                Paths.shellDir + "/assets/matugen/config.toml",
                "-m",
                Config.colors.isDarkMode ? "dark" : "light",
                "--source-color-index",
                "0"
            ];
            matugenProc.running = true;
        }
    }

    Process {
        id: matugenProc

        stderr: SplitParser {
            onRead: line => console.warn("[matugen]", line)
        }
    }

    FileView {
        id: matugenFile

        path: Paths.cacheDir + "/PurcleShell/matugen-colors.json"
        watchChanges: true
        // 仅 matugen 模式加载，避免其它模式下报缺失警告
        blockLoading: Config.colors.scheme !== "matugen"
        onFileChanged: reload()
        onLoadFailed: err => {
            if (err !== FileViewError.FileNotFound)
                console.warn("[matugen] 读取配色文件失败");
        }
    }

    // ==== pywal 缓存 ====
    FileView {
        id: walFile

        // 未启用 pywal 时不设路径，避免对不存在文件的加载警告
        path: Config.colors.scheme === "pywal" ? Paths.cacheDir + "/wal/colors.json" : ""
        watchChanges: true
        blockLoading: Config.colors.scheme !== "pywal"
        onFileChanged: reload()
        onLoadFailed: err => {
            if (err !== FileViewError.FileNotFound)
                console.warn("[pywal] 读取配色文件失败");
        }
    }

    // ==== 解析（JSON 异常时退回 null，由语义属性兜底为中性深色调） ====
    property int _matugenVersion: 0
    property int _walVersion: 0
    readonly property var m3Data: {
        root._matugenVersion;
        try {
            return JSON.parse(matugenFile.text());
        } catch (e) {
            return null;
        }
    }
    readonly property var walData: {
        root._walVersion;
        try {
            return JSON.parse(walFile.text());
        } catch (e) {
            return null;
        }
    }

    // FileView 加载成功后推进版本号触发重绑定
    Connections {
        target: matugenFile

        function onLoaded(): void {
            root._matugenVersion++;
        }
    }

    Connections {
        target: walFile

        function onLoaded(): void {
            root._walVersion++;
        }
    }

    function c(name: string, fallback: string): color {
        const map = Config.colors.scheme === "pywal" ? root.walData : root.m3Data;
        if (!map)
            return fallback;
        let v;
        if (Config.colors.scheme === "pywal") {
            v = root.walLookup(map, name);
        } else {
            const e = map[name];
            v = (e && e.startsWith("#")) ? e : (e && e.rgba ? e.rgba : e);
        }
        return v ? v : fallback;
    }

    // pywal 模式下：把 matugen 式语义键映射到 wal 调色板槽位
    function walLookup(map: var, name: string): var {
        const special = map.special ?? {};
        const colors = map.colors ?? {};
        switch (name) {
        case "surface_container_low":
            return special.background;
        case "surface_dim":
        case "surface_container_lowest":
            return colors.color0;
        case "surface_container":
        case "surface_container_high":
        case "surface_container_highest":
            return colors.color8;
        case "on_background":
            return special.foreground;
        case "on_surface_variant":
            return colors.color7;
        case "outline":
        case "outline_variant":
            return colors.color8;
        case "primary":
            return colors.color13 ?? colors.color5;
        case "tertiary":
            return colors.color12 ?? colors.color4;
        case "error":
            return colors.color1;
        case "on_primary":
            return special.background;
        default:
            return null;
        }
    }

    // ==== M3 色相派生（matugen 无独立色相槽，用 HCT 从源色固定色相生成） ====
    function hue(h: real, chroma: real, tone: real): color {
        return hctToRgb(h, chroma, tone);
    }

    function hctToRgb(h: real, c: real, t: real): color {
        const hueRad = h * Math.PI / 180;
        const a = c * Math.cos(hueRad);
        const bLab = c * Math.sin(hueRad);

        const fy = (t + 16) / 116;
        const fx = a / 500 + fy;
        const fz = fy - bLab / 200;

        let x = fx > 0.206897 ? Math.pow(fx, 3) : (fx - 16 / 116) / 7.787;
        let y = fy > 0.206897 ? Math.pow(fy, 3) : (fy - 16 / 116) / 7.787;
        let z = fz > 0.206897 ? Math.pow(fz, 3) : (fz - 16 / 116) / 7.787;

        x = x * 0.95047;
        z = z * 1.08883;

        let r = x * 3.2404542 + y * -1.5371385 + z * -0.4985314;
        let g = x * -0.9692660 + y * 1.8760108 + z * 0.0415560;
        let b = x * 0.0556434 + y * -0.2040259 + z * 1.0572252;

        r = r > 0.0031308 ? 1.055 * Math.pow(r, 1 / 2.4) - 0.055 : 12.92 * r;
        g = g > 0.0031308 ? 1.055 * Math.pow(g, 1 / 2.4) - 0.055 : 12.92 * g;
        b = b > 0.0031308 ? 1.055 * Math.pow(b, 1 / 2.4) - 0.055 : 12.92 * b;

        r = Math.max(0, Math.min(1, r));
        g = Math.max(0, Math.min(1, g));
        b = Math.max(0, Math.min(1, b));

        return Qt.rgba(r, g, b, 1.0);
    }

    // ================= 语义色（与 themes/*.qml 属性集一致，缺数据时回退中性深色） =================

    // ==== 背景 / 表面 ====
    readonly property color base: c("surface_container_low", "#1e1e2e")
    readonly property color mantle: c("surface_dim", "#181825")
    readonly property color crust: c("surface_container_lowest", "#11111b")
    readonly property color surface0: c("surface_container", "#313244")
    readonly property color surface1: c("surface_container_high", "#45475a")
    readonly property color surface2: c("surface_container_highest", "#585b70")

    // ==== 文字 ====
    readonly property color text: c("on_background", "#cdd6f4")
    readonly property color subtext1: c("on_surface_variant", "#a6adc8")
    readonly property color subtext0: c("on_surface_variant", "#a6adc8")
    readonly property color overlay2: c("on_surface_variant", "#9399b2")
    readonly property color overlay1: c("outline", "#7f849c")
    readonly property color overlay0: c("outline_variant", "#6c7086")

    // ==== 强调色 ====
    readonly property color mauve: c("primary", "#cba6f7")
    readonly property color blue: c("tertiary", "#89b4fa")
    readonly property color sky: hue(205, 52, 75)
    readonly property color green: hue(140, 48, 70)
    readonly property color teal: hue(175, 48, 68)
    readonly property color yellow: hue(90, 60, 78)
    readonly property color peach: hue(45, 70, 72)
    readonly property color red: c("error", "#f38ba8")
    readonly property color pink: hue(340, 55, 75)
    readonly property color lavender: hue(270, 38, 82)

    // ==== 功能色 ====
    readonly property color danger: c("error", "#f38ba8")
    readonly property color warning: yellow
    readonly property color success: green
    readonly property color shadow: "#000000"
    readonly property color onPrimary: c("on_primary", "#11111b")
}
