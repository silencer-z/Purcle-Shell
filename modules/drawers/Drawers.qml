pragma ComponentBehavior: Bound

import qs.Configs
import qs.modules.drawers
import qs.services
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        PanelWindow {
            id: win

            readonly property int barHeight: 32
            readonly property int borderThickness: Config.appearance.border.thickness
            readonly property bool needsKeyboard: Visibilities.launcher || Visibilities.clipboard || Visibilities.wallpaper || Visibilities.dashboard

            screen: scope.modelData
            WlrLayershell.namespace: "PurcleShell-drawers"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: win.needsKeyboard ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            color: "transparent"
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            mask: Region {
                x: 0
                y: 0
                width: 0
                height: 0
                intersection: Intersection.Intersect

                regions: regions.instances
            }

            Variants {
                id: regions

                model: panels.children

                Region {
                    required property Item modelData

                    x: modelData.x + win.borderThickness
                    y: modelData.y + win.barHeight
                    width: modelData.width
                    height: modelData.height
                    intersection: Intersection.Combine
                }
            }

            HyprlandFocusGrab {
                id: focusGrab

                active: win.needsKeyboard
                windows: [win]
                onCleared: {
                    Visibilities.launcher = false;
                    Visibilities.clipboard = false;
                    Visibilities.wallpaper = false;
                    Visibilities.dashboard = false;
                }
            }

            Border {
                barHeight: win.barHeight
            }

            Backgrounds {
                panels: panels
                barHeight: win.barHeight
            }

            Panels {
                id: panels

                borderThickness: win.borderThickness
                barHeight: win.barHeight
            }
        }
    }
}
