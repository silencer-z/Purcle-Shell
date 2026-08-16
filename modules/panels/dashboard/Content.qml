import "../widgets"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.components
import qs.Configs

ClippingRectangle {
    id: root

    required property int maxHeight

    radius: Config.appearance.border.rounding
    bottomLeftRadius: Config.appearance.border.rounding
    bottomRightRadius: Config.appearance.border.rounding
    topLeftRadius: 0
    topRightRadius: 0
    color: "transparent"

    property int currentIndex: 0
    property var widgetList: []
    property int currentWidgetIndex: -1

    readonly property int intrinsicHeight: 800

    function close() {
        Visibilities.dashboard = false;
    }

    function focusInput() {
        root.forceActiveFocus();
    }

    implicitWidth: 900
    implicitHeight: Math.min(root.intrinsicHeight, root.maxHeight)

    Rectangle {
        id: mainContainer
        anchors.fill: parent
        anchors.margins: 20
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth:true
                    Layout.preferredWidth:0
                    Layout.fillHeight: true
                    spacing:10

                    RowLayout {
                        WifiCapsule {
                            id: wifiCapsule
                            Layout.preferredHeight: 70
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                        }
                        BluetoothCapsule {
                            id: bluetoothCapsule
                            Layout.preferredHeight: 70
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                        }

                    }

                    ControlSlider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                    }

                    MediaWidget {
                        id:mediaWidget
                        Layout.preferredHeight: 150
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                    }

                    CalendarPanelWidget {
                        id:calendarWidget
                        Layout.preferredHeight: 310
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                    }
                }

                ColumnLayout {
                    Layout.fillWidth:true
                    Layout.preferredWidth:0
                    Layout.fillHeight: true

                    NotificationWidget {
                        id: notificationWidget
                        Layout.fillWidth: true
                        Layout.fillHeight:true
                        Layout.alignment: Qt.AlignCenter
                    }
                }

            }

            Item {
                Layout.fillHeight: true
            }

            BottomPanel {
                id: bottomPanel
                Layout.preferredHeight: 70
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
            }
        }
    }
}
