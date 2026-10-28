pragma ComponentBehavior: Bound

import qs.components
import qs.modules.panels.launcher as Launcher
import qs.modules.panels.clipboard as Clipboard
import qs.modules.panels.wallpaper as Wallpaper
import qs.modules.panels.sidebar as Sidebar
import qs.modules.panels.task as Task
import qs.Configs
import qs.services
import QtQuick

Item {
    id: root

    required property int borderThickness
    required property int barHeight
    property bool dismissBackground: false

    signal dismissed()

    readonly property alias launcher: launcher
    readonly property alias clipboard: clipboard
    readonly property alias wallpaper: wallpaper
    readonly property alias sidebar: sidebar
    readonly property alias task: task

    anchors.fill: parent
    anchors.margins: root.borderThickness
    anchors.topMargin: root.barHeight

    focus: true
    Keys.onEscapePressed: Visibilities.hideAll()

    // 面板打开时点击空白区域关闭（在 PanelWrapper 之下）
    MouseArea {
        anchors.fill: parent
        enabled: root.dismissBackground
        z: -1
        onClicked: {
            Visibilities.hideAll();
            root.dismissed();
        }
    }

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

    PanelWrapper {
        id: task

        panelName: "task"
        edge: "bottom"
        fullBleed: true
        maxHeight: parent.height - Config.appearance.padding.large
        contentComponent: Component {
            Task.Content {
                maxHeight: task.maxHeight
                panelWidth: root.width
            }
        }

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
}
