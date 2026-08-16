import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components
import qs.services

Rectangle {
    id: root

    property alias buttonText: label.text
    property alias buttonIcon: iconText.text
    property alias buttonColor: iconText.color
    property string command: ""
    property alias iconSize: iconText.iconSize
    property alias font: label.font

    signal clicked()

    color: Theme.surface0
    radius: 8

    Process {
        id: commandProcess

        command: ["sh", "-c", command]
        running: false
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        MaterialSymbol {
            id: iconText

            iconSize: 18
            color: Theme.blue
        }

        StyledText {
            id: label

            Layout.fillWidth: true
            font.pixelSize: 14
            color: Theme.text
        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            parent.color = Theme.surface1;
        }
        onExited: {
            parent.color = Theme.surface0;
        }
        onClicked: {
            root.clicked();
            if (command) {
                commandProcess.command = ["sh", "-c", command];
                commandProcess.running = true;
            }
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.BezierSpline
        }

    }

}
