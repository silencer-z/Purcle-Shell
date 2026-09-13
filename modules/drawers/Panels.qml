pragma ComponentBehavior: Bound

import qs.components
import qs.modules.panels.launcher as Launcher
import qs.modules.panels.clipboard as Clipboard
import qs.modules.panels.wallpaper as Wallpaper
import qs.modules.panels.sidebar as Sidebar
import qs.Configs
import qs.services
import QtQuick

Item {
    id: root

    required property int borderThickness
    required property int barHeight

    readonly property alias launcher: launcher
    readonly property alias clipboard: clipboard
    readonly property alias wallpaper: wallpaper
    readonly property alias sidebar: sidebar

    anchors.fill: parent
    anchors.margins: root.borderThickness
    anchors.topMargin: root.barHeight

    focus: true
    Keys.onEscapePressed: Visibilities.hideAll()

    PanelWrapper {
        id: launcher

        panelName: "launcher"
        edge: "bottom"
        maxHeight: {
            let max = parent.height - Config.appearance.padding.large;
            if (Visibilities.clipboard)
                max -= clipboard.intrinsicHeight;
            return Math.max(180, max);
        }
        contentComponent: Component {
            Launcher.Content {
                maxHeight: launcher.maxHeight
            }
        }

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }

    PanelWrapper {
        id: clipboard

        panelName: "clipboard"
        edge: "bottom"
        maxHeight: {
            let max = parent.height - Config.appearance.padding.large;
            if (Visibilities.launcher)
                max -= launcher.intrinsicHeight;
            return Math.max(180, max);
        }
        contentComponent: Component {
            Clipboard.Content {
                maxHeight: clipboard.maxHeight
            }
        }

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: launcher.height > 0 ? launcher.top : parent.bottom
    }

    PanelWrapper {
        id: wallpaper

        panelName: "wallpaper"
        edge: "left"
        maxHeight: parent.height
        contentComponent: Component {
            Wallpaper.Content {
                maxHeight: wallpaper.maxHeight
            }
        }

        anchors.top: parent.top
    }

    PanelWrapper {
        id: sidebar

        panelName: "sidebar"
        edge: "right"
        maxHeight: parent.height
        contentComponent: Component {
            Sidebar.Content {
                maxHeight: sidebar.maxHeight
            }
        }

        anchors.top: parent.top
    }
}
