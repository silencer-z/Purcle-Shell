import "./widgets" as Widgets
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Configs
import qs.components as Components
import qs.services

Item {
    id: root

    required property ShellScreen screen
    property var popouts: null
    readonly property int exclusiveZone: bar.height
    readonly property var currentMonitor: Brightness.getMonitorForScreen(root.screen)
    property int barRadius: 0
    property int barHMargin: 0

    implicitHeight: bar.height
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    Rectangle {
        id: bar

        height: Config.appearance.bar.height
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.barHMargin
        anchors.rightMargin: root.barHMargin
        color: Theme.base
        radius: root.barRadius

        Item {
            anchors.fill: parent

            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Widgets.Board {
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: Config.appearance.bar.margin
                }

                Widgets.ActiveApps {
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: Config.appearance.bar.margin
                }

            }

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                Widgets.Workspaces {
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                }

            }

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Widgets.SysTray {
                    // barWrapper:wrapper

                    popouts: root.popouts
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Widgets.WidgetsGroup {
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    monitor: currentMonitor
                }

                Widgets.Clock {
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: Config.appearance.bar.margin
                }

            }

        }

    }

}
