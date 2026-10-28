import "./modules/drawers"
import qs.services
import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    id: root

    // 预热：应用数据、IPC 注册、OSD 监听
    Component.onCompleted: {
        AppModel.warmUp();
        ShellIPC;
        OSD;
        HyprlandData;
        SystemTheme;
    }

    Drawers {}

    GlobalShortcut {
        name: "launcher"
        description: qsTr("Start a launcher to execute applications")
        onPressed: {
            Visibilities.togglePanel("launcher");
        }
    }

    GlobalShortcut {
        name: "clipboard"
        description: qsTr("Start a clipboard")
        onPressed: {
            Visibilities.togglePanel("clipboard");
        }
    }

    GlobalShortcut {
        name: "dashboard"
        description: qsTr("Start a dashboard for system controls")
        onPressed: {
            Visibilities.togglePanel("sidebar");
        }
    }

    GlobalShortcut {
        name: "wallpaper"
        description: qsTr("Start a wallpaper selector")
        onPressed: {
            Visibilities.togglePanel("wallpaper");
        }
    }

    GlobalShortcut {
        name: "taskview"
        description: qsTr("Toggle task view (workspace previews)")
        onPressed: {
            Visibilities.togglePanel("task");
        }
    }
}