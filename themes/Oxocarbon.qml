import QtQuick
import Quickshell

pragma Singleton

// 预设：Oxocarbon Dark
Singleton {
    readonly property string presetId: "oxocarbon"
    readonly property string displayName: "Oxocarbon"
    readonly property bool dark: true

    // ==== 背景 / 表面 ====
    readonly property color base: "#161616"
    readonly property color mantle: "#131313"
    readonly property color crust: "#111111"
    readonly property color surface0: "#262626"
    readonly property color surface1: "#333333"
    readonly property color surface2: "#3d3d3d"

    // ==== 文字 ====
    readonly property color text: "#f2f4f8"
    readonly property color subtext1: "#ececec"
    readonly property color subtext0: "#d6d6d6"
    readonly property color overlay2: "#bebebe"
    readonly property color overlay1: "#9e9e9e"
    readonly property color overlay0: "#808080"

    // ==== 强调色 ====
    readonly property color mauve: "#a48cf2"
    readonly property color blue: "#8cb4ff"
    readonly property color sky: "#59c2ff"
    readonly property color green: "#78ffab"
    readonly property color teal: "#52e9c2"
    readonly property color yellow: "#f0deaa"
    readonly property color peach: "#ff9e64"
    readonly property color red: "#ff5458"
    readonly property color pink: "#ff7a93"
    readonly property color lavender: "#bfa4ff"

    // ==== 功能色 ====
    readonly property color danger: "#ff5458"
    readonly property color warning: "#f0deaa"
    readonly property color success: "#78ffab"
    readonly property color shadow: "#000000"
    readonly property color onPrimary: "#161616"
}
