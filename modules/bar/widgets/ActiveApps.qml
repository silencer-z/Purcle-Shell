import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.components
import qs.services

BarWidget {
    id: root
    color: "transparent"

    property var runningApps: {
        const apps = new Set();
        for (let app of ToplevelManager.toplevels.values) {
            if (app && app.appId)
                apps.add(app.appId);
        }
        return Array.from(apps);
    }

    property var pinnedApps: [
        { appId: "zen-browser", name: "Zen Browser",        icon: "zenbrowser.svg",launch: "zen-browser" },
        { appId: "code",        name: "Visual Studio Code", icon: "code.svg",      launch: "code" },
        { appId: "kitty",       name: "Terminal",           icon: "gnubash.svg",   launch: "kitty" }
    ]

    // 常见 appId -> 显示名映射，避免显示原始 id
    property var appNameMap: {
        "zen-browser": "Zen Browser",
        "code": "Code",
        "kitty": "Terminal",
        "org.kde.dolphin": "Dolphin",
        "firefox": "Firefox",
        "chromium": "Chromium",
        "google-chrome": "Chrome",
        "com.obsproject.Studio": "OBS Studio",
        "org.gnome.Nautilus": "Files",
        "org.gnome.TextEditor": "Text Editor"
    }

    function displayName(appId: string): string {
        if (appNameMap[appId])
            return appNameMap[appId];
        if (!appId)
            return "Desktop";
        return appId.charAt(0).toUpperCase() + appId.slice(1).replace(/[-_]/g, " ");
    }

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
            id: appRowLayout
            spacing: 15
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                id: appRepeater
                model: root.pinnedApps

                delegate: Item {
                    id: delegateRoot

                    Layout.fillHeight: true
                    Layout.preferredWidth: 20

                    property bool isActive: root.activeIndex === index

                    AppIcon {
                        id: icon
                        colorize: true
                        source: modelData.icon
                        width: 20
                        height: 20

                        // 动态染色：激活 / 运行中 / 未运行
                        color: {
                            if (delegateRoot.isActive)
                                return Theme.mauve;
                            if (root.runningApps.indexOf(modelData.appId) >= 0)
                                return Theme.blue;
                            return Theme.overlay0;
                        }

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: isActive ? -2 : 0

                        Behavior on anchors.verticalCenterOffset {
                            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            const cmd = modelData.launch || modelData.appId;
                            if (cmd) {
                                // Hyprland ≥0.56 lua IPC：exec 走 hl.dsp.exec_cmd，双引号/反斜杠转义
                                const escaped = cmd.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
                                Hyprland.dispatch('hl.dsp.exec_cmd("' + escaped + '")');
                            }
                        }
                    }
                }
            }

            Row {
                id: activeApp
                StyledText {
                    text: "[ "
                    color: Theme.mauve
                    font.bold: true
                }
                StyledText {
                    text: root.displayName(root.currentApp)
                    color: Theme.mauve
                    font.bold: true
                }
                StyledText {
                    text: " ]"
                    color: Theme.mauve
                    font.bold: true
                }
            }
        }

        Rectangle {
            id: indicator
            property var activeItem: root.activeIndex !== -1 ? appRepeater.itemAt(root.activeIndex) : activeApp
            readonly property real targetWidth: activeItem ? activeItem.width * 0.9 : 0
            x: activeItem ? activeItem.x + (activeItem.width - targetWidth) / 2 : 0
            y: parent.height - height + 2
            height: 3
            radius: 1.5
            color: Theme.mauve
            width: targetWidth

            Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.InOutCubic } }
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutCubic } }
        }
    }
}