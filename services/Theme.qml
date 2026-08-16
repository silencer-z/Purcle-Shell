pragma Singleton

import QtQuick

// 统一配色：语义化颜色，当前基于 Catppuccin Mocha
// 后续可切换为 ServiceColor.m3Colors / matugen 动态主题
QtObject {
    id: root

    // ==== 背景 / 表面 ====
    readonly property color base: "#1e1e2e"        // 主背景（顶栏/面板）
    readonly property color mantle: "#181825"      // 更深背景
    readonly property color crust: "#11111b"       // 最暗背景（文字反色用）
    readonly property color surface0: "#313244"    // 次级表面（搜索栏/卡片）
    readonly property color surface1: "#45475a"    // 悬停/强调表面
    readonly property color surface2: "#585b70"    // 按压/选中表面

    // ==== 文字 ====
    readonly property color text: "#cdd6f4"
    readonly property color subtext1: "#a6adc8"
    readonly property color subtext0: "#a6adc8"
    readonly property color overlay2: "#9399b2"
    readonly property color overlay1: "#7f849c"
    readonly property color overlay0: "#6c7086"    // 弱化文字

    // ==== 强调色 ====
    readonly property color mauve: "#cba6f7"       // 主强调（激活）
    readonly property color blue: "#89b4fa"        // 信息/链接
    readonly property color sky: "#89dceb"
    readonly property color green: "#a6e3a1"
    readonly property color teal: "#94e2d5"
    readonly property color yellow: "#f9e2af"
    readonly property color peach: "#fab387"
    readonly property color red: "#f38ba8"
    readonly property color pink: "#f5c2e7"
    readonly property color lavender: "#b4befe"

    // ==== 功能色 ====
    readonly property color danger: "#f38ba8"
    readonly property color warning: "#f9e2af"
    readonly property color success: "#a6e3a1"
    readonly property color shadow: "#000000"
    readonly property color onPrimary: "#11111b"
}
