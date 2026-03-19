import "./widgets" as Widgets
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components as Components
import qs.services

Item {
    id: root

    required property ShellScreen screen
    readonly property int exclusiveZone: bar.height
    readonly property var currentMonitor: Brightness.getMonitorForScreen(root.screen)
    property int barRadius: 0
    property int barHMargin: 0
    property int barVMargin: 10

    implicitHeight: bar.height
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    Rectangle {
        id: bar

        height: 32
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.barHMargin
        anchors.rightMargin: root.barHMargin
        color: "#1e1e2e"
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
                    Layout.leftMargin: 7
                }

                Widgets.ActiveApps {
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 7
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
                    Layout.topMargin: 3
                    Layout.bottomMargin: 3
                }

            }

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Widgets.SysTray {
                    // barWrapper:wrapper

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
                    Layout.rightMargin: 7
                }

            }

        }

    }

}
