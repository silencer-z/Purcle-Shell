import QtQuick
import Quickshell.Io

JsonObject {
    property bool enabledWallpaper: true
    property string wallpaperDir: "/home/orz/Pictures/Wallpapers"
    property string transition: "random"
    property int visibleWallpaper: 3
    property bool transitionLowPerfMode: false
    property int transitionDuration: 300
    // 按当前主题色盘重新着色壁纸；与 scheme 独立
    property bool recolor: false
}