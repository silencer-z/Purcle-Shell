import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components

PanelWidget {
    id: root

    color: "#313244"
    border.color: "#45475a"
    radius: 20
    height: 300

    ColumnLayout {
        anchors.fill: parent
        spacing: 8
        anchors.margins:5

        RowLayout {
            Layout.fillWidth: true
            implicitHeight:35
            spacing: 8

            Rectangle{
                implicitHeight:25
                implicitWidth:25
                Layout.leftMargin:10
                radius:10
                color:"transparent"


                IconText{
                    anchors.centerIn:parent
                    text:"arrow_back_ios"
                    size:20
                }
                MouseArea{
                    anchors.fill:parent
                    hoverEnabled:true
                    onClicked: {
                        let newDate = new Date(grid.year, grid.month - 1, 1);
                        grid.year = newDate.getFullYear();
                        grid.month = newDate.getMonth();
                    }
                }
            }

            StyledText {
                text: "%1 / %2".arg(grid.year).arg(grid.month + 1)
                Layout.fillWidth:true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                font.bold: true
                color: "white"
            }

            Rectangle{
                implicitHeight:25
                implicitWidth:25
                Layout.rightMargin:10
                radius:10
                color:"transparent"

                IconText{
                    anchors.centerIn:parent
                    text:"arrow_forward_ios"
                    size:20
                }
                MouseArea{
                    anchors.fill:parent
                    hoverEnabled:true
                    onClicked: {
                        let newDate = new Date(grid.year, grid.month + 1, 1);
                        grid.year = newDate.getFullYear();
                        grid.month = newDate.getMonth();
                    }
                }
            }
        }


        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: 7

                StyledText {
                    text: {
                        let firstDay = Qt.locale().firstDayOfWeek;
                        let dayIndex = (firstDay + index) % 7;
                        return Qt.locale().dayName(dayIndex, Locale.ShortFormat);
                    }
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    font.bold: true
                    color: "#a6adc8"
                }
            }
        }

        MonthGrid {
            id: grid

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            month: new Date().getMonth()
            year: new Date().getFullYear()
            locale: Qt.locale()

            delegate:Item {
                Layout.fillWidth:true
                Layout.fillHeight:true

                Rectangle{
                    anchors.centerIn:parent
                    width :Math.min(parent.width,parent.height) * 0.8
                    height:width
                    radius: width/2
                    visible:model.today
                    color:"#89b4fa"
                }

                StyledText {
                    anchors.centerIn: parent
                    text: model.day
                    color: model.today ? "#1e1e2e" : "white"
                    opacity: model.month === grid.month ? 1 : 0.4
                    font.pixelSize: 16
                    font.bold: model.today
                }
            }

        }
    }
}