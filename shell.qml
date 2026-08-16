import "./components" as Components
import "./modules/bar"
import "./modules/drawers"
import "./modules/popups" as Popups
import qs.services
import Qt5Compat.GraphicalEffects
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
                property int cornerRadius: 20
                WlrLayershell.namespace: "PurcleShell"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                anchors.top: true
                anchors.left: true
                anchors.right: true
                // 连续色块高度 = 内容(32) + 圆角(20)，与 drawer 的 barHeight 对齐
                implicitHeight: bar.height + barPanel.cornerRadius
                screen: modelData
                exclusiveZone: barPanel.implicitHeight

                Item {
                    anchors.fill: parent
                    layer.enabled: true

                    // 连续背景：填充圆角之间的中心区域，使顶栏与 drawer 无缝衔接
                    Rectangle {
                        anchors.fill: parent
                        color: "#1e1e2e"
                    }

                    Bar {
                        id: bar
                        screen: scope.modelData
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }
                    Components.RoundCorner {
                        id: leftCorner
                        size: barPanel.cornerRadius
                        color: "#1e1e2e"
                        corner: Components.RoundCorner.CornerEnum.TopLeft
                        anchors {
                            top: bar.bottom
                            left: parent.left
                        }
                    }
                    Components.RoundCorner {
                        id: rightCorner
                        size: barPanel.cornerRadius
                        color: "#1e1e2e"
                        corner: Components.RoundCorner.CornerEnum.TopRight
                        anchors {
                            right: parent.right
                            top: bar.bottom
                        }
                    }
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
