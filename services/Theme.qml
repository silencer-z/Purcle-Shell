pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.Configs
import qs.services
import qs.themes

// 统一配色门面：所有消费方继续使用 Theme.xxx 语义色，不感知底层方案。
// scheme = "preset"  → themes/ 预设调色板（不改壁纸）
// scheme = "matugen" → Color 单例；着色关闭时随壁纸取色，打开时冻结上次色板
Singleton {
    id: root

    readonly property string scheme: Config.colors.scheme
    readonly property string presetName: Config.colors.presetName

    // 不用 binding 直接读 qs.themes 单例：初次求值时对方可能尚未就绪且不会重试。
    // Color 与 Theme 同模块，作为启动兜底；onCompleted / 方案变化时再切到真实 palette。
    property var presets: []
    property QtObject palette: Color

    readonly property bool isDarkMode: palette?.dark ?? true

    function presetList(): var {
        return [Catppuccin, Gruvbox, Dracula, Oxocarbon].filter(p => !!p);
    }

    function currentPalette(): QtObject {
        if (scheme === "matugen")
            return Color;
        return presetByName(presetName) || presetList()[0] || Color;
    }

    function refreshPalette(): void {
        if (root.presets.length === 0)
            root.presets = presetList();
        root.palette = currentPalette();
    }

    function refreshPresetList(): void {
        root.presets = presetList();
    }

    function presetByName(name: string): QtObject {
        const list = root.presets.length ? root.presets : presetList();
        for (let i = 0; i < list.length; i++) {
            if (list[i].presetId === name)
                return list[i];
        }
        return null;
    }

    Component.onCompleted: {
        if (Config.colors.scheme === "pywal") {
            Config.colors.scheme = "preset";
            Config.wallpaper.recolor = true;
        }
        root.refreshPresetList();
        root.refreshPalette();
    }
    onSchemeChanged: root.refreshPalette()
    onPresetNameChanged: {
        if (root.scheme === "preset")
            root.palette = currentPalette();
    }

    function usePreset(name: string): void {
        const preset = presetByName(name);
        if (!preset)
            return;
        Config.colors.scheme = "preset";
        Config.colors.presetName = name;
    }

    function useMatugen(): void {
        Config.colors.scheme = "matugen";
        Color.regenerate(false);
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
