import QtQuick
import Quickshell

pragma Singleton

// 预设：Gruvbox Dark
Singleton {
    readonly property string presetId: "gruvbox"
    readonly property string displayName: "Gruvbox"
    readonly property bool dark: true

    // ==== 背景 / 表面 ====
    readonly property color base: "#282828"
    readonly property color mantle: "#1d2021"
    readonly property color crust: "#161819"
    readonly property color surface0: "#3c3836"
    readonly property color surface1: "#504945"
    readonly property color surface2: "#665c54"

    // ==== 文字 ====
    readonly property color text: "#ebdbb2"
    readonly property color subtext1: "#d5c4a1"
    readonly property color subtext0: "#bdae93"
    readonly property color overlay2: "#a89984"
    readonly property color overlay1: "#928374"
    readonly property color overlay0: "#7c6f64"

    // ==== 强调色 ====
    readonly property color mauve: "#d3869b"
    readonly property color blue: "#83a598"
    readonly property color sky: "#8ec07c"
    readonly property color green: "#b8bb26"
    readonly property color teal: "#8ec07c"
    readonly property color yellow: "#fabd2f"
    readonly property color peach: "#fe8019"
    readonly property color red: "#fb4934"
    readonly property color pink: "#d3869b"
    readonly property color lavender: "#83a598"

    // ==== 功能色 ====
    readonly property color danger: "#fb4934"
    readonly property color warning: "#fabd2f"
    readonly property color success: "#b8bb26"
    readonly property color shadow: "#000000"
    readonly property color onPrimary: "#282828"
}
