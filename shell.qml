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
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                anchors.top: true
                anchors.left: true
                anchors.right: true
                implicitHeight: bar.implicitHeight
                screen: modelData
                exclusiveZone: barPanel.implicitHeight

                Bar {
                    id: bar
                    screen: scope.modelData
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
