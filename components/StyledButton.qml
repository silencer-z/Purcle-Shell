import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Configs
import qs.components
import qs.services

// Aylur button 语言：
// normal  → surface0 背景 + inset 边框（surface2）
// hover   → surface1 背景
// checked → mauve 背景 + onPrimary 前景
// flat    → 透明背景、无边框，仅 hover 变色
Rectangle {
    id: root

    property alias buttonText: label.text
    property alias buttonIcon: iconText.text
    property alias buttonColor: iconText.color
    property string command: ""
    property alias iconSize: iconText.size
    property alias font: label.font
    property bool checked: false
    property bool flat: false

    signal clicked()

    radius: 10
    border.width: flat ? 0 : 1
    border.color: checked ? Theme.mauve : Theme.surface2
    color: {
        if (checked)
            return Theme.mauve;
        if (mouseArea.containsMouse)
            return flat ? Theme.surface0 : Theme.surface1;
        return flat ? "transparent" : Theme.surface0;
    }

    Behavior on color {
        ColorAnim {}
    }

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

            size: 18
            color: {
                if (root.checked)
                    return Theme.onPrimary;
                if (root.buttonColor !== Theme.blue)
                    return root.buttonColor;
                return mouseArea.containsMouse ? Theme.mauve : Theme.blue;
            }
        }

        StyledText {
            id: label

            Layout.fillWidth: true
            font.pixelSize: 14
            color: root.checked ? Theme.onPrimary : Theme.text
        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.clicked();
            if (command) {
                commandProcess.command = ["sh", "-c", command];
                commandProcess.running = true;
            }
        }
    }

}
