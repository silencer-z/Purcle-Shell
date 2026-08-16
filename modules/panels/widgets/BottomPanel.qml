import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components
import qs.services

PanelWidget {
    // { icon: "lock", text: "Lock", color: Theme.blue, command: "loginctl lock-session" },
    // { icon: "bedtime", text: "Suspend", color: Theme.mauve, command: "systemctl suspend" }

    id: root
    // color: Theme.surface0
    radius: 20
    

    property string currentPowerProfile: "balanced"
    // Power profiles data
    readonly property var powerProfiles: [{
        "icon": "eco",
        "profile": "power-saver",
        "color": Theme.green
    }, {
        "icon": "balance",
        "profile": "balanced",
        "color": Theme.blue
    }, {
        "icon": "speed",
        "profile": "performance",
        "color": Theme.danger
    }]
    // Session commands
    readonly property var sessionActions: [{
        "icon": "logout",
        "text": "Logout",
        "color": Theme.peach,
        "command": "hyprctl dispatch exit"
    }, {
        "icon": "restart_alt",
        "text": "Reboot",
        "color": Theme.green,
        "command": "systemctl reboot"
    }, {
        "icon": "power_settings_new",
        "text": "Shutdown",
        "color": Theme.danger,
        "command": "systemctl poweroff"
    }]

    function executeSessionCommand(command) {
        sessionProcess.command = ["sh", "-c", command];
        sessionProcess.running = true;
    }

    function closeDashboard() {
        Visibilities.dashboard = false;
    }

    Component.onCompleted: {
        SysInfo.loadUserInfo();
        getPowerProfile.running = true;
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft
            color: "transparent"
            radius: 8

            RowLayout {
                anchors.fill: parent
                spacing: 10

                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: Theme.mauve
                    Layout.leftMargin:10

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "person"
                        size: 25
                        color: Theme.text
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: SysInfo.userName || "User"
                        font.pixelSize: 22
                        font.bold: true
                        color: Theme.text
                    }

                    StyledText {
                        text: "Uptime: " + (SysInfo.uptime || "Unknown") + " | Packs: " + (SysInfo.packages || "0")
                        font.pixelSize: 13
                        color: Theme.subtext1
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 3

            Rectangle {
                Layout.preferredWidth: powerLayout.implicitWidth + 12
                Layout.preferredHeight: powerLayout.implicitHeight + 12
                color: "transparent"
                radius: 8

                // Power Profile Buttons
                RowLayout {
                    id: powerLayout

                    anchors.centerIn: parent
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6

                    Repeater {
                        model: root.powerProfiles

                        delegate: Rectangle {
                            Layout.preferredWidth: 45
                            Layout.preferredHeight: 45
                            radius: 10
                            color: mouseArea.containsMouse ? Qt.lighter(modelData.color, 1.2) : (currentPowerProfile === modelData.profile ? modelData.color : Theme.surface1)

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: modelData.icon
                                size: 22
                                color: "white"
                            }

                            MouseArea {
                                id: mouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    currentPowerProfile = modelData.profile;
                                    setPowerProfile.command = ["powerprofilesctl", "set", modelData.profile];
                                    setPowerProfile.running = true;
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                    }

                }

            }

            Rectangle {
                Layout.preferredWidth: 2
                Layout.fillHeight: true
                Layout.topMargin: 15
                Layout.bottomMargin: 15
                color: Theme.surface1
            }

            Rectangle {
                Layout.preferredWidth: sessionLayout.implicitWidth + 12
                Layout.preferredHeight: powerLayout.implicitHeight + 12
                color: "transparent"
                radius: 8

                // Session Action Buttons
                RowLayout {
                    id: sessionLayout

                    anchors.centerIn: parent
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6

                    Repeater {
                        model: root.sessionActions

                        delegate: Rectangle {
                            Layout.preferredWidth: 45
                            Layout.preferredHeight: 45
                            radius: 10
                            color: mouseArea.containsMouse ? modelData.color : Theme.surface1

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: modelData.icon
                                size: 22
                                color: "white"
                                visible: Layout.columnSpan === 1
                            }

                            MouseArea {
                                id: mouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    executeSessionCommand(modelData.command);
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                    }

                }

            }

        }

    }

    // Process for getting current power profile
    Process {
        id: getPowerProfile

        command: ["powerprofilesctl", "get"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.currentPowerProfile = text.trim()
        }

    }

    // Process for setting power profile
    Process {
        id: setPowerProfile

        command: []
        running: false
        onExited: getPowerProfile.running = true
    }

    // Process for session commands
    Process {
        id: sessionProcess

        command: []
        running: false
        onExited: closeDashboard()
    }

}
