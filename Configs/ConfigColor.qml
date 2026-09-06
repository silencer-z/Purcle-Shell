import Quickshell.Io

// 统一配色方案配置
// scheme:     "preset"  预设方案（themeWallpapers 可为每个预设绑定壁纸，切换主题时自动应用）
//             "matugen" 动态方案（壁纸变化时自动从壁纸提取色板）
//             "pywal"   外部 pywal 驱动（监听 ~/.cache/wal/colors.json，颜色与壁纸均由 wal 管理）
// presetName: 预设 id，见 themes/*.qml 的 presetId
// isDarkMode: 仅作用于 matugen（-m dark|light）
JsonObject {
    property string scheme: "preset"
    property string presetName: "catppuccin"
    property bool isDarkMode: true
    property ThemeWallpapersComponent themeWallpapers: ThemeWallpapersComponent {}

    component ThemeWallpapersComponent: JsonObject {
        property string catppuccin: ""
        property string gruvbox: ""
        property string dracula: ""
        property string oxocarbon: ""
    }
}
