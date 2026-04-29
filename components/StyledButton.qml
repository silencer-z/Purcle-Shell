import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components

Rectangle {
    id: root

    property alias buttonText: label.text
    property alias buttonIcon: iconText.text
    property alias buttonColor: iconText.color
    property string command: ""
    property alias iconSize: iconText.iconSize
    property alias font: label.font

    signal clicked()

    color: "#313244"
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
            color: "#89b4fa"
        }

        StyledText {
            id: label

            Layout.fillWidth: true
            font.pixelSize: 14
            color: "#cdd6f4"
        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            parent.color = "#45475a";
        }
        onExited: {
            parent.color = "#313244";
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
