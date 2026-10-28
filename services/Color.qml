pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.Configs
import qs.services

// 动态配色提供者：当 Config.colors.scheme 为 "matugen" 时，
// Theme 会把本单例作为调色板使用。暴露与 themes/*.qml 预设完全相同的语义属性集。
//
// 默认：壁纸变化时自动运行 matugen 生成 ~/.cache/PurcleShell/matugen-colors.json。
// 着色（Config.wallpaper.recolor）打开时冻结上次提取的色板，不再随当前壁纸重跑；
// 暗亮切换仍对提取源壁纸（matugenSource）生效。
Singleton {
    id: root

    readonly property bool available: m3Data !== null
    property bool dark: Config.colors.isDarkMode
    readonly property bool recolor: Config.wallpaper.recolor

    readonly property string wallpaper: {
        Paths.currentWallpaper; // eslint-disable-line
        return Paths.currentWallpaper;
    }

    onWallpaperChanged: root.regenerate(false)
    onDarkChanged: root.regenerate(true)
    onRecolorChanged: {
        if (root.recolor) {
            generateTimer.stop();
            if (matugenProc.running)
                matugenProc.running = false;
            if (Config.colors.scheme === "matugen" && !Config.colors.matugenSource && root.wallpaper)
                Config.colors.matugenSource = root.wallpaper;
            return;
        }
        root.regenerate(false);
    }
    Component.onCompleted: root.regenerate(false)

    function extractSource(): string {
        if (root.recolor && Config.colors.matugenSource)
            return Config.colors.matugenSource;
        return root.wallpaper;
    }

    // force=true：着色模式下仍跑（暗亮切换、色板文件缺失）
    function regenerate(force): void {
        if (Config.colors.scheme !== "matugen")
            return;
        if (root.recolor && force !== true)
            return;
        if (!root.extractSource())
            return;
        generateTimer.restart();
    }

    Timer {
        id: generateTimer

        interval: 500
        repeat: false
        onTriggered: {
            const src = root.extractSource();
            if (!src)
                return;
            if (Config.colors.matugenSource !== src)
                Config.colors.matugenSource = src;
            matugenProc.command = [
                "matugen",
                "image",
                src,
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
        blockLoading: Config.colors.scheme !== "matugen"
        onFileChanged: reload()
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound && Config.colors.scheme === "matugen") {
                if (!matugenProc.running && !generateTimer.running)
                    root.regenerate(true);
                return;
            }
            if (err !== FileViewError.FileNotFound)
                console.warn("[matugen] 读取配色文件失败");
        }
    }

    property int _matugenVersion: 0
    readonly property var m3Data: {
        root._matugenVersion;
        try {
            return JSON.parse(matugenFile.text());
        } catch (e) {
            return null;
        }
    }

    Connections {
        target: matugenFile

        function onLoaded(): void {
            root._matugenVersion++;
        }
    }

    readonly property var recolorHexes: {
        const map = root.m3Data;
        if (!map)
            return [];
        const keys = [
            "background", "surface_container_lowest", "surface_container_low",
            "surface_container", "on_background", "on_surface_variant",
            "primary", "primary_container", "secondary", "secondary_container",
            "tertiary", "error", "source_color"
        ];
        const out = [];
        const seen = {};
        for (let i = 0; i < keys.length; i++) {
            const e = map[keys[i]];
            const v = (e && e.startsWith("#")) ? e : (e && e.rgba ? e.rgba : e);
            if (!v || typeof v !== "string" || !v.startsWith("#"))
                continue;
            const hex = v.slice(0, 7).toLowerCase();
            if (seen[hex])
                continue;
            seen[hex] = true;
            out.push(hex);
        }
        return out;
    }

    function c(name: string, fallback: string): color {
        const map = root.m3Data;
        if (!map)
            return fallback;
        const e = map[name];
        const v = (e && e.startsWith("#")) ? e : (e && e.rgba ? e.rgba : e);
        return v ? v : fallback;
    }

    // ==== M3 色相派生（matugen 无独立色相槽，用 HCT 从源色固定色相生成） ====
    function accent(slot: string, h: real, chroma: real, tone: real, fallback: string): color {
        return hue(h, chroma, tone);
    }

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

    readonly property color base: c("surface_container_low", "#1e1e2e")
    readonly property color mantle: c("surface_dim", "#181825")
    readonly property color crust: c("surface_container_lowest", "#11111b")
    readonly property color surface0: c("surface_container", "#313244")
    readonly property color surface1: c("surface_container_high", "#45475a")
    readonly property color surface2: c("surface_container_highest", "#585b70")

    readonly property color text: c("on_background", "#cdd6f4")
    readonly property color subtext1: c("on_surface_variant", "#a6adc8")
    readonly property color subtext0: c("on_surface_variant", "#a6adc8")
    readonly property color overlay2: c("on_surface_variant", "#9399b2")
    readonly property color overlay1: c("outline", "#7f849c")
    readonly property color overlay0: c("outline_variant", "#6c7086")

    readonly property color mauve: c("primary", "#cba6f7")
    readonly property color blue: c("tertiary", "#89b4fa")
    readonly property color sky: accent("sky", 205, 52, 75, "#89dceb")
    readonly property color green: accent("green", 140, 48, 70, "#a6e3a1")
    readonly property color teal: accent("teal", 175, 48, 68, "#94e2d5")
    readonly property color yellow: accent("yellow", 90, 60, 78, "#f9e2af")
    readonly property color peach: accent("peach", 45, 70, 72, "#fab387")
    readonly property color red: c("error", "#f38ba8")
    readonly property color pink: accent("pink", 340, 55, 75, "#f5c2e7")
    readonly property color lavender: accent("lavender", 270, 38, 82, "#b4befe")

    readonly property color danger: c("error", "#f38ba8")
    readonly property color warning: yellow
    readonly property color success: green
    readonly property color shadow: "#000000"
    readonly property color onPrimary: c("on_primary", "#11111b")
}
