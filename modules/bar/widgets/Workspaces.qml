import QtQuick
import Quickshell.Hyprland

import qs.components as Components

Components.BarWidget {
    id: root
    /* 检查Hyprland是否初始化完成 */
    readonly property bool ready : Hyprland.workspaces && Hyprland.workspaces.values && Hyprland.focusedWorkspace

    readonly property int realWorkspaceCount: ready ? Hyprland.workspaces.values.length:1
    readonly property int maxWorkspaceCount: ready ? Hyprland.workspaces.values[realWorkspaceCount-1]?.id:1
    readonly property int showWorkspaceCount: ready ? Math.max(5, maxWorkspaceCount):5


    function calculateDynamicWidth() {

        const count = showWorkspaceCount;
        if (count === 0) return 180;

        const baseWidth = 175 / (count + 2.5);
        const totalWorkspaceWidth = baseWidth * (count + 1.5);
        const spacing = Math.max(2, 10 - count) * (count - 1);
        const padding = 10;

        return Math.ceil(totalWorkspaceWidth + spacing + padding);
    }

    implicitWidth: calculateDynamicWidth()

    color: "transparent"
    radius: 8

    Component.onCompleted: {
        Hyprland.refreshWorkspaces();
        Hyprland.refreshMonitors();
    }

    Row {
        id: workspaceRow
        
        anchors {
            fill: parent
            margins: 0
        }
        
        spacing: Math.max(2, 10 - root.showWorkspaceCount)
        
        // 使用 Repeater 替代 ListView
        Repeater {
            model: ready ? root.showWorkspaceCount : 5
            
            delegate: Item {
                id: workspaceContainer

                property int workspaceId: index + 1
                property var workspaceData: Hyprland.workspaces.values.find(ws => ws.id === workspaceId)
                property bool isPlaceholder: !workspaceData 
                property bool isActive: ready && (Hyprland.focusedWorkspace.id === workspaceId)
                
                width: workspaceRect.width
                height: workspaceRow.height

                Rectangle {
                    id: workspaceRect

                    color: {if (isActive) return "#cba6f7";if (isPlaceholder) return "#6c7086";return "#89b4fa";}

                    width: calculateWidth()
                    height: workspaceRow.height * 0.8 + 1
                    anchors.centerIn: parent
                    radius: 10

                    function calculateWidth() {
                        const totalWorkspaces = root.showWorkspaceCount;
                        const availableWidth = 175;
                        const baseWidth = availableWidth / (totalWorkspaces + 2.5);
                        
                        // 占位符和未激活的工作区宽度相同
                        return isActive ? baseWidth * 2.5 : baseWidth;
                    }

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + workspaceId)
                    }
                    Behavior on width {NumberAnimation {duration: 200 ;easing.type: Easing.InOutQuad}}
                }


            }
        }
    }
}
