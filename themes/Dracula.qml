import QtQuick
import Quickshell

pragma Singleton

// 预设：Dracula
Singleton {
    readonly property string presetId: "dracula"
    readonly property string displayName: "Dracula"
    readonly property bool dark: true

    // ==== 背景 / 表面 ====
    readonly property color base: "#282a36"
    readonly property color mantle: "#21222c"
    readonly property color crust: "#191a21"
    readonly property color surface0: "#343746"
    readonly property color surface1: "#3d4050"
    readonly property color surface2: "#44475a"

    // ==== 文字 ====
    readonly property color text: "#f8f8f2"
    readonly property color subtext1: "#cdd3e0"
    readonly property color subtext0: "#b4bccf"
    readonly property color overlay2: "#9ba3bd"
    readonly property color overlay1: "#7e87a5"
    readonly property color overlay0: "#5d6785"

    // ==== 强调色 ====
    readonly property color mauve: "#bd93f9"
    readonly property color blue: "#8be9fd"
    readonly property color sky: "#8be9fd"
    readonly property color green: "#50fa7b"
    readonly property color teal: "#8ff0e8"
    readonly property color yellow: "#f1fa8c"
    readonly property color peach: "#ffb86c"
    readonly property color red: "#ff5555"
    readonly property color pink: "#ff79c6"
    readonly property color lavender: "#9aa5fc"

    // ==== 功能色 ====
    readonly property color danger: "#ff5555"
    readonly property color warning: "#f1fa8c"
    readonly property color success: "#50fa7b"
    readonly property color shadow: "#000000"
    readonly property color onPrimary: "#282a36"
}
