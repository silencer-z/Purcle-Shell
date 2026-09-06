pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.Configs

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")

    readonly property string pictures: {
        const dir = Quickshell.env("XDG_PICTURES_DIR");
        if (!dir)
            return `${home}/Pictures`;
        return dir.startsWith("/") ? dir : `${home}/${dir}`;
    }
    readonly property string videos: {
        const dir = Quickshell.env("XDG_VIDEOS_DIR");
        if (!dir)
            return `${home}/Videos`;
        return dir.startsWith("/") ? dir : `${home}/${dir}`;
    }

    readonly property string rootDir: Quickshell.shellDir
    readonly property string configDir: Quickshell.env("XDG_CONFIG_HOME") || `${home}/.config`
    readonly property string shellDir: `${configDir}/quickshell`
    readonly property string stateDir: Quickshell.env("XDG_STATE_HOME") || `${home}/.local/state`

    readonly property string cacheDir: Quickshell.env("XDG_CACHE_HOME") || `${home}/.cache`
    readonly property string currentWallpaperFile: `${cacheDir}/PurcleShell/wallpaper.txt`
    property int wallpaperVersion: 0
    readonly property string currentWallpaper: {
        root.wallpaperVersion; // 依赖文件重载信号，保证响应 wallpaper.txt 变化
        return wallpaperPath.text().trim();
    }

    readonly property string wallpaperDir: Config.wallpaper.wallpaperDir

    readonly property string recordDir: `${videos}/record`


    function pathToBreadcrumb(path) {
        if (!path || typeof path !== 'string')
            return '';

        let cleanPath = path;

        // Remove file:// protocol
        if (cleanPath.startsWith('file://'))
            cleanPath = cleanPath.substring(7);

        // Remove qrc:// protocol
        if (cleanPath.startsWith('qrc://'))
            cleanPath = cleanPath.substring(6);

        // Remove qrc:/ protocol
        if (cleanPath.startsWith('qrc:/'))
            cleanPath = cleanPath.substring(5);

        // Remove leading slashes (handles //, ///, etc.)
        cleanPath = cleanPath.replace(/^\/+/, '');

        // Split by forward slashes or backslashes
        const parts = cleanPath.split(/[\/\\]+/).filter(part => part.length > 0);

        return parts.join(' > ');
    }

    FileView {
        id: wallpaperPath

        path: `${root.cacheDir}/PurcleShell/wallpaper.txt`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.wallpaperVersion++
        onLoadFailed: root.wallpaperVersion++
    }
}
