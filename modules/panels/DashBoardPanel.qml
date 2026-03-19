import "./widgets"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.components

Item {
    id: root

    required property var panelWrapper
    property int currentIndex: 0
    property var widgetList: []
    property int currentWidgetIndex: -1

    function close() {
        console.log("dashboard close");
    }

    function init() {
        console.log("dashboard init");
    }

    implicitWidth: 900
    implicitHeight: 800

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
                        Layout.preferredHeight: 120
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
