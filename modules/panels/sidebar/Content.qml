pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Configs
import qs.components
import qs.services
import "../widgets"

// 右侧面板内容（表面由 drawers/RightPanelPath 绘制）
Item {
    id: root

    required property int maxHeight

    function close() {
        Visibilities.sidebar = false;
    }

    function focusInput() {
    }

    readonly property int filletSize: Config.appearance.border.rounding
    readonly property int contentPadding: Config.appearance.padding.normal
    readonly property int bodyWidth: Config.appearance.sizes.panelSide

    implicitWidth: root.filletSize + root.bodyWidth + root.contentPadding * 2
    implicitHeight: root.maxHeight

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: root.filletSize + root.contentPadding
        anchors.rightMargin: root.contentPadding
        anchors.topMargin: root.contentPadding
        anchors.bottomMargin: root.contentPadding
        spacing: Config.appearance.spacing.small

        SystemSection {
            Layout.fillWidth: true
        }

        QuickSliders {
            Layout.fillWidth: true
        }

        MediaSection {
            Layout.fillWidth: true
        }

        ConnectSection {
            Layout.fillWidth: true
        }

        NotificationWidget {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 160
        }

        CalendarSection {
            Layout.fillWidth: true
        }

        BottomSection {
            Layout.fillWidth: true
        }
    }
}
