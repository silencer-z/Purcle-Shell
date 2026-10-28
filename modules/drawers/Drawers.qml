pragma ComponentBehavior: Bound

import qs.Configs
import qs.modules.bar
import qs.modules.bar.popouts as BarPopouts
import qs.modules.drawers
import qs.modules.osd as OsdUi
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

        BarExclusion {
            screen: scope.modelData
            reservedZone: win.barHeight
        }

        PanelWindow {
            id: win

            readonly property int barHeight: bar.height
            readonly property int borderThickness: Config.appearance.border.thickness
            readonly property bool needsKeyboard: Visibilities.launcher || Visibilities.clipboard || Visibilities.wallpaper || Visibilities.sidebar || Visibilities.task || popouts.hasCurrent
            // Exclusive 与 FocusGrab 同时生效会立刻 cleared、面板秒关；错开一拍再抓
            property bool grabArmed: false

            onNeedsKeyboardChanged: {
                if (win.needsKeyboard) {
                    win.grabArmed = false;
                    grabArmTimer.restart();
                } else {
                    grabArmTimer.stop();
                    win.grabArmed = false;
                }
            }

            screen: scope.modelData
            WlrLayershell.namespace: "PurcleShell-drawers"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: win.needsKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

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

                Region {
                    id: barRegion

                    x: 0
                    y: 0
                    width: win.width
                    height: win.barHeight
                }

                Region {
                    id: popoutRegion

                    x: popouts.x
                    y: popouts.y
                    width: popouts.width
                    height: popouts.height
                    intersection: Intersection.Combine
                }

                Region {
                    id: notificationRegion

                    x: notificationPopups.x
                    y: notificationPopups.y
                    width: notificationPopups.width
                    height: notificationPopups.height
                    intersection: Intersection.Combine
                }

                Region {
                    regions: panelRegions.instances
                }

                // Exclusive 时点击不再穿透到下层窗口，FocusGrab 关不掉；面板打开时吃满屏点击
                Region {
                    x: 0
                    y: 0
                    width: win.needsKeyboard ? win.width : 0
                    height: win.needsKeyboard ? win.height : 0
                    intersection: Intersection.Combine
                }
            }

            Variants {
                id: panelRegions

                model: [panels.launcher, panels.clipboard, panels.task, panels.wallpaper, panels.sidebar]

                Region {
                    required property Item modelData

                    x: modelData.x + win.borderThickness
                    y: modelData.y + win.barHeight
                    width: modelData.width
                    height: modelData.height
                    intersection: Intersection.Combine
                }
            }

            Timer {
                id: grabArmTimer

                interval: 200
                repeat: false
                onTriggered: win.grabArmed = true
            }

            HyprlandFocusGrab {
                id: focusGrab

                active: win.needsKeyboard && win.grabArmed
                windows: [win]
                onCleared: {
                    Visibilities.launcher = false;
                    Visibilities.clipboard = false;
                    Visibilities.wallpaper = false;
                    Visibilities.sidebar = false;
                    Visibilities.task = false;
                    popouts.close();
                }
            }

            // 打开任一面板时关闭弹出面板（互斥）
            Connections {
                target: Visibilities

                function onLauncherChanged() {
                    if (Visibilities.launcher)
                        popouts.close();
                }

                function onClipboardChanged() {
                    if (Visibilities.clipboard)
                        popouts.close();
                }

                function onWallpaperChanged() {
                    if (Visibilities.wallpaper)
                        popouts.close();
                }

                function onSidebarChanged() {
                    if (Visibilities.sidebar)
                        popouts.close();
                }

                function onTaskChanged() {
                    if (Visibilities.task)
                        popouts.close();
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
                dismissBackground: win.needsKeyboard
                onDismissed: popouts.close()
            }

            BarPopouts.Popouts {
                id: popouts

                barHeight: win.barHeight
                maxHeight: win.height - win.barHeight - Config.appearance.margin.large
            }

            NotificationPopups {
                id: notificationPopups

                barHeight: win.barHeight
            }

            OsdUi.OSDOverlay {
                barHeight: win.barHeight
                screen: scope.modelData
            }

            Bar {
                id: bar

                screen: scope.modelData
                popouts: popouts
            }
        }
    }

    // 1x1 隐形窗口：全屏 drawers 窗口本身无法占位（ExclusionMode.Ignore），
    // 用它顶边 reservedZone 像素把普通窗口顶到 bar 之下（caelestia Exclusions 同款技巧）。
    // 注意：不要声明与 PanelWindow 原生属性同名的自定义属性（会静默遮蔽导致失效）。
    component BarExclusion: PanelWindow {
        id: exclusion

        property int reservedZone: 0

        exclusiveZone: exclusion.reservedZone
        WlrLayershell.namespace: "PurcleShell-exclusion"
        WlrLayershell.exclusionMode: ExclusionMode.Normal
        anchors.top: true
        color: "transparent"
        mask: Region {
            x: 0
            y: 0
            width: 0
            height: 0
        }
        implicitWidth: 1
        implicitHeight: 1
    }
}