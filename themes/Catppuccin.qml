import QtQuick
import Quickshell

pragma Singleton

// 预设：Catppuccin Mocha
Singleton {
    // ==== 元数据（presetId / displayName，供 Theme 枚举） ====
    readonly property string presetId: "catppuccin"
    readonly property string displayName: "Catppuccin"
    readonly property bool dark: true

    // ==== 背景 / 表面 ====
    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color surface2: "#585b70"

    // ==== 文字 ====
    readonly property color text: "#cdd6f4"
    readonly property color subtext1: "#a6adc8"
    readonly property color subtext0: "#a6adc8"
    readonly property color overlay2: "#9399b2"
    readonly property color overlay1: "#7f849c"
    readonly property color overlay0: "#6c7086"

    // ==== 强调色 ====
    readonly property color mauve: "#cba6f7"
    readonly property color blue: "#89b4fa"
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
