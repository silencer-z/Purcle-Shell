pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.Configs
import qs.services
import qs.themes

// 统一配色门面：所有消费方继续使用 Theme.xxx 语义色，不感知底层方案。
// scheme = "preset"  → themes/ 预设调色板，切换主题时自动应用该主题绑定的壁纸
// scheme = "matugen" → 壁纸变化时 Color 单例自动提取色板（壁纸 → 颜色）
// scheme = "pywal"   → 监听 wal 缓存（外部 wal -i 驱动颜色与壁纸）
Singleton {
    id: root

    readonly property string scheme: Config.colors.scheme
    readonly property string presetName: Config.colors.presetName

    // 单例创建顺序问题：binding 初次求值时 qs.themes 单例尚未就绪且不会重试，
    // 用 generation 在创建完成后强制重求值
    property int generation: 0

    // 预设元数据（UI 枚举用；壁纸绑定 key = presetId）
    readonly property var presets: {
        generation;
        return [Catppuccin, Gruvbox, Dracula, Oxocarbon];
    }

    readonly property QtObject palette: {
        generation;
        if (scheme === "matugen" || scheme === "pywal")
            return Color;
        return presetByName(presetName) ?? Catppuccin;
    }

    readonly property bool isDarkMode: palette.dark

    function presetByName(name: string): QtObject {
        for (let i = 0; i < presets.length; i++) {
            if (presets[i].presetId === name)
                return presets[i];
        }
        return null;
    }

    Component.onCompleted: {
        root.generation++;
    }

    // ==== 方案切换 ====
    function usePreset(name: string): void {
        const preset = presetByName(name);
        if (!preset)
            return;
        Config.colors.scheme = "preset";
        Config.colors.presetName = name;
        // 预设绑定了壁纸时一并应用（主题 → 壁纸）
        const wp = presetWallpaper(name);
        if (wp)
            Wallpapers.setWallpaper(wp);
    }

    function useMatugen(): void {
        Config.colors.scheme = "matugen";
        Color.regenerate();
    }

    function usePywal(): void {
        Config.colors.scheme = "pywal";
    }

    // ==== 预设的壁纸绑定 ====
    function presetWallpaper(name: string): string {
        const tw = Config.colors.themeWallpapers;
        switch (name) {
        case "catppuccin":
            return tw.catppuccin;
        case "gruvbox":
            return tw.gruvbox;
        case "dracula":
            return tw.dracula;
        case "oxocarbon":
            return tw.oxocarbon;
        default:
            return "";
        }
    }

    function assignWallpaperToPreset(name: string, path: string): void {
        if (!presetByName(name))
            return;
        const tw = Config.colors.themeWallpapers;
        switch (name) {
        case "catppuccin":
            tw.catppuccin = path;
            break;
        case "gruvbox":
            tw.gruvbox = path;
            break;
        case "dracula":
            tw.dracula = path;
            break;
        case "oxocarbon":
            tw.oxocarbon = path;
            break;
        }
    }

    function assignCurrentWallpaperToPreset(name: string): void {
        root.assignWallpaperToPreset(name, Paths.currentWallpaper);
    }

    // ==== 语义色代理（保持原有 API 不变） ====
    readonly property color base: palette.base
    readonly property color mantle: palette.mantle
    readonly property color crust: palette.crust
    readonly property color surface0: palette.surface0
    readonly property color surface1: palette.surface1
    readonly property color surface2: palette.surface2

    readonly property color text: palette.text
    readonly property color subtext1: palette.subtext1
    readonly property color subtext0: palette.subtext0
    readonly property color overlay2: palette.overlay2
    readonly property color overlay1: palette.overlay1
    readonly property color overlay0: palette.overlay0

    readonly property color mauve: palette.mauve
    readonly property color blue: palette.blue
    readonly property color sky: palette.sky
    readonly property color green: palette.green
    readonly property color teal: palette.teal
    readonly property color yellow: palette.yellow
    readonly property color peach: palette.peach
    readonly property color red: palette.red
    readonly property color pink: palette.pink
    readonly property color lavender: palette.lavender

    readonly property color danger: palette.danger
    readonly property color warning: palette.warning
    readonly property color success: palette.success
    readonly property color shadow: palette.shadow
    readonly property color onPrimary: palette.onPrimary
}
