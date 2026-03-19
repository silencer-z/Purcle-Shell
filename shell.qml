import "./components" as Components
import "./modules/bar"
import "./modules/panels" as Panels
import "./modules/popups" as Popups
import "./services" as Services
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
                implicitHeight: bar.height + barPanel.cornerRadius + 20
                screen: modelData
                exclusiveZone: bar.implicitHeight

                Item {
                    anchors.fill: parent // 填充整个窗口
                    layer.enabled: true

                    Bar {
                        id: bar
                        screen: scope.modelData
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

                    layer.effect: DropShadow {
                        color: "#80000000"
                        radius: 16
                        samples: radius * 2
                        cached: true
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

    Panels.PanelWrapper {
        id: panelWrapper
    }

    GlobalShortcut {
        name: "launcher"
        description: qsTr("Start a launcher to execute applications")
        onPressed: {
            panelWrapper.open(Quickshell.shellPath("modules/panels/LaunchPanel.qml"), {
            });
        }
    }

    GlobalShortcut {
        name: "clipboard"
        description: qsTr("Start a clipboard")
        onPressed: {
            panelWrapper.open(Quickshell.shellPath("modules/panels/ClipBoardPanel.qml"), {
            });
        }
    }

    GlobalShortcut {
        name: "dashboard"
        description: qsTr("Start a dashboard for system controls")
        onPressed: {
            panelWrapper.open(Quickshell.shellPath("modules/panels/DashBoardPanel.qml"), {
            });
        }
    }
    GlobalShortcut {
        name:"wallpaper"
        description: qsTr("start a wallpaper selector")
        onPressed:{
            panelWrapper.open(Quickshell.shellPath("modules/panels/WallpaperPanel.qml"), {
            });
        }
    }
}
