import Quickshell.Io

// 统一配色方案配置
// scheme:        "preset"  预设方案（themes/*.qml）
//                "matugen" 动态方案（从提取源壁纸跑 matugen；着色打开时冻结上次色板）
// presetName:    预设 id，见 themes/*.qml 的 presetId
// isDarkMode:    仅作用于 matugen（-m dark|light）
// matugenSource: 上次用于提取的壁纸路径；着色模式下暗亮切换仍针对该图
// applySystem:   把当前 Theme 色板同步到 Hyprland / GTK / Qt / Zen
JsonObject {
    property string scheme: "preset"
    property string presetName: "catppuccin"
    property bool isDarkMode: true
    property bool applySystem: true
    property string matugenSource: ""
    property var themeWallpapers: ({
        "catppuccin": "",
        "gruvbox": "",
        "dracula": "",
        "oxocarbon": ""
    })
}
