import "./modules/drawers"
import "./modules/popups" as Popups
import qs.services
import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    id: root

    // 预热应用数据（面板懒加载，但服务状态应在启动时就绪）
    Component.onCompleted: AppModel.warmUp()

    Popups.NotificationPopup{}

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
}