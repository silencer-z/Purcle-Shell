pragma ComponentBehavior: Bound

import qs.modules.panels.launcher as Launcher
import qs.modules.panels.clipboard as Clipboard
import qs.modules.panels.wallpaper as Wallpaper
import qs.modules.panels.dashboard as Dashboard
import QtQuick

Item {
    id: root

    required property int borderThickness
    required property int barHeight

    readonly property alias launcher: launcher
    readonly property alias clipboard: clipboard
    readonly property alias wallpaper: wallpaper
    readonly property alias dashboard: dashboard

    anchors.fill: parent
    anchors.margins: root.borderThickness
    anchors.topMargin: root.barHeight

    Launcher.Wrapper {
        id: launcher

        panels: root
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }

    Clipboard.Wrapper {
        id: clipboard

        panels: root
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: launcher.height > 0 ? launcher.top : parent.bottom
    }

    Wallpaper.Wrapper {
        id: wallpaper

        panels: root
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: clipboard.height > 0 ? clipboard.top : (launcher.height > 0 ? launcher.top : parent.bottom)
    }

    Dashboard.Wrapper {
        id: dashboard

        panels: root
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }
}
