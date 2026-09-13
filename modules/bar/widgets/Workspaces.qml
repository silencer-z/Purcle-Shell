import QtQuick
import Quickshell.Hyprland
import qs.Configs
import qs.components as Components
import qs.services

Components.BarWidget {
    id: root

    // 焦点与工作区列表都取自 HyprlandState（quickshell 0.3.1 在 Hyprland 0.56 下状态不可靠）
    readonly property int showWorkspaceCount: Math.max(5, HyprlandState.focusedWorkspaceId, ...HyprlandState.workspaceIds)

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
    radius: Config.appearance.bar.widgetRadius




    Row {
        id: workspaceRow
        
        anchors {
            fill: parent
            margins: 0
        }
        
        spacing: Math.max(2, 10 - root.showWorkspaceCount)
        
        // 使用 Repeater 替代 ListView
        Repeater {
            model: root.showWorkspaceCount
            
            delegate: Item {
                id: workspaceContainer

                property int workspaceId: index + 1
                property bool isPlaceholder: !HyprlandState.workspaceIds.includes(workspaceId)
                property bool isActive: HyprlandState.focusedWorkspaceId === workspaceId
                
                width: workspaceRect.width
                height: workspaceRow.height

                Rectangle {
                    id: workspaceRect

                    color: {if (isActive) return Theme.mauve;if (isPlaceholder) return Theme.overlay0;return Theme.blue;}

                    width: calculateWidth()
                    height: workspaceRow.height * 0.8 + 1
                    anchors.centerIn: parent
                    radius: Config.appearance.rounding.small

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
                        onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + workspaceId + " })")
                    }
                    Behavior on width {
                        NumberAnimation {
                            duration: Config.appearance.animations.durations.emphasizedAccel
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Config.appearance.animations.curves.standard
                        }
                    }
                }


            }
        }
    }

    // 滚轮切换工作区（NoButton 不拦截点击）
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0)
                Hyprland.dispatch('hl.dsp.focus({ workspace = "r-1" })');
            else if (wheel.angleDelta.y < 0)
                Hyprland.dispatch('hl.dsp.focus({ workspace = "r+1" })');
        }
    }
}
