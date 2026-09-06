pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

// 弹出面板集合：按 currentName 激活对应 Loader，同一时间只显示一个。
// Loader 右上锚定：展开动画向左/向下进行时内容相对 bar 与右缘保持不动。
// 淡入立即激活；淡出完成后再销毁（caelestia Comp 时序），避免内容瞬间消失。
Item {
    id: root

    property int maxHeight: 0
    property string currentName: ""
    property var popouts: null

    readonly property Loader activeLoader: children.find(c => c.name !== undefined && c.name === root.currentName) ?? null
    readonly property Item activeItem: activeLoader?.item ?? null

    implicitWidth: activeItem?.implicitWidth ?? 0
    implicitHeight: Math.min(activeItem?.implicitHeight ?? 0, root.maxHeight)

    PopoutLoader {
        name: "audio"
        sourceComponent: AudioPopout {}
    }

    PopoutLoader {
        name: "network"
        sourceComponent: NetworkPopout {
            maxHeight: root.maxHeight
        }
    }

    PopoutLoader {
        name: "bluetooth"
        sourceComponent: BluetoothPopout {
            maxHeight: root.maxHeight
        }
    }

    PopoutLoader {
        name: "battery"
        sourceComponent: BatteryPopout {}
    }

    Repeater {
        model: ScriptModel {
            values: SystemTray.items.values
        }

        PopoutLoader {
            id: trayLoader

            required property SystemTrayItem modelData

            name: "tray-" + modelData.id
            sourceComponent: TrayMenuPopout {
                menu: trayLoader.modelData.menu
                popouts: root.popouts
            }
        }
    }

    component PopoutLoader: Loader {
        id: popoutLoader

        property string name: ""

        active: false
        opacity: 0
        anchors.top: parent.top
        anchors.right: parent.right

        states: State {
            name: "active"
            when: root.currentName === popoutLoader.name

            PropertyChanges {
                target: popoutLoader
                opacity: 1
                active: true
            }
        }

        transitions: [
            Transition {
                to: "active"

                SequentialAnimation {
                    PropertyAction {
                        target: popoutLoader
                        property: "active"
                    }
                    NumberAnimation {
                        target: popoutLoader
                        property: "opacity"
                        duration: 150
                    }
                }
            },
            Transition {
                from: "active"

                SequentialAnimation {
                    NumberAnimation {
                        target: popoutLoader
                        property: "opacity"
                        duration: 150
                    }
                    PropertyAction {
                        target: popoutLoader
                        property: "active"
                    }
                }
            }
        ]
    }
}