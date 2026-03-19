pragma Singleton

import Quickshell
import Quickshell.Io

import qs.services

Singleton{
    id: root

    property alias appearance: adapter.appearance
    property alias colors: adapter.colors
    property alias wallpaper: adapter.wallpaper
    property alias widgets: adapter.widgets

    FileView {
        path: Quickshell.shellPath("configurations.json")
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: err => {
            if (err !== FileViewError.FileNotFound) {
                console.log("Failed to read config files");
            }
        }
        onLoaded: console.log("start load config")
        onAdapterUpdated: writeAdapter()
        onSaveFailed: err => {
            console.log("Failed to save config", FileViewError.toString(err));
        }

        JsonAdapter {
            id: adapter

            property ConfigAppearance appearance: ConfigAppearance {}
            property ConfigColor colors: ConfigColor {}
            property ConfigWallpaper wallpaper: ConfigWallpaper {}
            property var widgets: [
                {}
            ]
        }
    }
}