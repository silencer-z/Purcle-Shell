pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Configs
import qs.services

// Task View：满宽底栏，5 列网格，预览保持屏幕比例（表面由 BottomFullBleedPanelPath 绘制）
Item {
    id: root

    required property int maxHeight
    required property int panelWidth

    readonly property int columns: HyprlandData.defaultWorkspaceCount
    readonly property int filletSize: Config.appearance.border.rounding
    readonly property int panelPadding: Config.appearance.padding.large
    readonly property int gridSpacing: Config.appearance.spacing.normal
    readonly property var monitor: HyprlandData.primaryMonitor()
    readonly property real screenAspect: {
        const w = monitor?.width ?? 1920;
        const h = monitor?.height ?? 1080;
        return w / Math.max(1, h);
    }
    readonly property int cardWidth: Math.max(
        120,
        Math.floor((panelWidth - panelPadding * 2 - (columns - 1) * gridSpacing) / columns)
    )
    readonly property int previewHeight: Math.round(cardWidth / screenAspect)
    readonly property var entries: HyprlandData.workspaceEntries()
    readonly property int rowCount: Math.max(1, Math.ceil(entries.length / columns))
    readonly property int gridWidth: panelWidth - panelPadding * 2
    readonly property int gridHeight: rowCount * previewHeight + (rowCount - 1) * gridSpacing
    readonly property int contentHeight: filletSize + gridHeight + panelPadding * 2
    readonly property int intrinsicHeight: Math.min(maxHeight, contentHeight)

    implicitWidth: panelWidth
    implicitHeight: intrinsicHeight

    function focusInput(): void {
        root.forceActiveFocus();
    }

    function close(): void {
        Visibilities.task = false;
    }

    Component.onCompleted: {
        if (Visibilities.task)
            HyprlandData.updateAll();
    }

    Connections {
        target: Visibilities

        function onTaskChanged(): void {
            if (Visibilities.task)
                HyprlandData.updateAll();
        }
    }

    Keys.onEscapePressed: root.close()

    Flickable {
        anchors.fill: parent
        anchors.topMargin: root.filletSize + root.panelPadding
        anchors.leftMargin: root.panelPadding
        anchors.rightMargin: root.panelPadding
        anchors.bottomMargin: root.panelPadding
        contentWidth: width
        contentHeight: root.gridHeight
        boundsBehavior: Flickable.StopAtBounds
        interactive: root.contentHeight > root.maxHeight
        clip: true

        GridLayout {
            width: parent.width
            columns: root.columns
            rowSpacing: root.gridSpacing
            columnSpacing: root.gridSpacing

            Repeater {
                model: root.entries

                TaskWorkspaceCard {
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.preferredHeight: root.previewHeight
                    Layout.column: index % root.columns
                    Layout.row: Math.floor(index / root.columns)
                    entry: modelData
                    previewLive: Visibilities.task
                    cardWidth: root.cardWidth
                    previewHeight: root.previewHeight
                }
            }
        }
    }
}
