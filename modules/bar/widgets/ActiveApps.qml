import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import qs.components


// TODO)) 添加对应用名称的处理，不显示原始id名而是显示更为通用的名字

BarWidget {
    id: root
    color: "transparent"

    property var appList: ToplevelManager.toplevels.values

    property var runningApps: []

    property var pinnedApps: [
        { appId: "zen-browser", name: "Zen Browser",        icon: "zenbrowser.svg",launch: "zen-browser" },
        { appId: "code",        name: "Visual Studio Code", icon: "code.svg",      launch: "code" },
        { appId: "kitty",       name: "Terminal",           icon: "gnubash.svg",   launch: "kitty" }
    ]

    property string currentApp: ToplevelManager?.activeToplevel?.appId ?? "Desktop"

    property int activeIndex: {
        for (let i = 0; i < pinnedApps.length; ++i) {
            if (pinnedApps[i].appId === currentApp) {
                return i;
            }
        }
        return -1;
    }

    Item {
        implicitWidth: appRowLayout.implicitWidth
        implicitHeight: appRowLayout.implicitHeight

        RowLayout {
            id:appRowLayout
            spacing: 15
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                id:appRepeater
                model: root.pinnedApps

                delegate: Item {
                    id: delegateRoot

                    // spacing: 4
                    Layout.fillHeight:true
                    Layout.preferredWidth:20

                    property bool isActive: root.activeIndex === index

                    StyledIcon {
                        id: icon
                        colorize: true
                        source: modelData.icon
                        width: 20
                        height: 20
                        
                        // 动态染色逻辑保持不变
                        color: {
                            if (delegateRoot.isActive)
                                return "#cba6f7";
                            if (root.runningApps.indexOf(modelData.appId) >= 0)
                                return "#89b4fa";
                            return "#6c7086";
                        }

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: isActive ? -2 : 0

                        Behavior on anchors.verticalCenterOffset {
                            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                        }
                    }

                    // MouseArea 现在覆盖整个 ColumnLayout
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // console.log("You clicked App ", modelData.name)
                            // 可以添加启动应用的逻辑
                            // Hyprland.dispatch("exec [workspace special] " + modelData.launch)
                        }
                    }
                }
            }

            Row {
                id:activeApp
                StyledText {
                    text: "[ "
                    color: "#cba6f7"
                    font.bold:true
                }
                StyledText {
                    text: root.currentApp
                    color: "#cba6f7"
                    font.bold:true

                }
                StyledText {
                    text: " ]"
                    color: "#cba6f7"
                    font.bold:true
                }
            }
        }

        Rectangle {
            id: indicator
            property var activeItem: root.activeIndex !== -1 ? appRepeater.itemAt(root.activeIndex) : activeApp
            readonly property real targetWidth: activeItem ? activeItem.width * 0.9 : 0
            x: activeItem ? activeItem.x + (activeItem.width - targetWidth) / 2 : 0
            y: parent.height - height +2
            height: 3
            radius: 1.5 // 圆角
            color: "#cba6f7" // 使用活动状态的颜色
            width:targetWidth

            Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.InOutCubic } }
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutCubic } }
        }
    }
    onAppListChanged: {
        let apps = new Set();
        for (let app of ToplevelManager.toplevels.values) {
            if (app && app.appId) {
                apps.add(app.appId);
            }
        }
        runningApps = Array.from(apps);
    }
}
