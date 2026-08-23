import "./modules/bar"
import "./modules/drawers"
import "./modules/popups" as Popups
import qs.services
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        Scope {
            id: scope
            required property ShellScreen modelData
            PanelWindow {
                id: barPanel
                WlrLayershell.namespace: "PurcleShell"
                WlrLayershell.exclusionMode: ExclusionMode.Normal
                color: "transparent"
                anchors.top: true
                anchors.left: true
                anchors.right: true
                // 可视高度 32；窗口加高以容纳下方 tooltip，输入区用 mask 限定在 32px
                implicitHeight: 100
                screen: modelData
                exclusiveZone: 32

                Bar {
                    id: bar
                    screen: scope.modelData
                }

                mask: Region {
                    x: bar.x
                    y: bar.y
                    width: bar.width
                    height: bar.height
                }
            }
        }
    }

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
            Visibilities.togglePanel("dashboard");
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
