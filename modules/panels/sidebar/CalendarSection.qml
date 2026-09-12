pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Configs
import qs.components
import qs.services

// 紧凑日历（可折叠）
PanelWidget {
    id: root

    property bool collapsed: false

    color: Theme.surface0

    Behavior on color {
        ColorAnim {}
    }

    implicitHeight: collapsed ? headerRow.implicitHeight + Config.appearance.padding.normal * 2 : calendarCol.implicitHeight + Config.appearance.padding.normal * 2

    Behavior on implicitHeight {
        NumberAnim {}
    }

    ColumnLayout {
        id: calendarCol

        anchors.fill: parent
        spacing: Config.appearance.spacing.small

        // ==== 标题行（点击折叠） ====
        RowLayout {
            id: headerRow

            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small

            MaterialSymbol {
                text: "calendar_month"
                size: 16
                color: Theme.mauve
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("%1 %2").arg(Qt.locale().monthName(grid.month, Locale.LongFormat)).arg(grid.year)
                color: Theme.text
                font.pixelSize: 13
                font.bold: true
            }

            // 上个月
            MaterialSymbol {
                text: "chevron_left"
                size: 16
                color: prevHover.hovered ? Theme.text : Theme.overlay0

                MouseArea {
                    id: prevHover

                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const d = new Date(grid.year, grid.month - 1, 1);
                        grid.year = d.getFullYear();
                        grid.month = d.getMonth();
                    }
                }
            }

            // 下个月
            MaterialSymbol {
                text: "chevron_right"
                size: 16
                color: nextHover.hovered ? Theme.text : Theme.overlay0

                MouseArea {
                    id: nextHover

                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const d = new Date(grid.year, grid.month + 1, 1);
                        grid.year = d.getFullYear();
                        grid.month = d.getMonth();
                    }
                }
            }

            // 回到今天
            MaterialSymbol {
                text: "today"
                size: 15
                color: todayHover.hovered ? Theme.mauve : Theme.overlay0

                MouseArea {
                    id: todayHover

                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        grid.year = new Date().getFullYear();
                        grid.month = new Date().getMonth();
                    }
                }
            }

            // 折叠
            MaterialSymbol {
                text: root.collapsed ? "expand_more" : "expand_less"
                size: 16
                color: Theme.overlay0

                TapHandler {
                    onTapped: root.collapsed = !root.collapsed
                }
            }
        }

        // ==== 星期表头 ====
        RowLayout {
            visible: !root.collapsed
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: 7

                delegate: Item {
                    required property int index

                    Layout.fillWidth: true

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            const firstDay = Qt.locale().firstDayOfWeek;
                            return Qt.locale().dayName((firstDay + index) % 7, Locale.ShortFormat);
                        }
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.subtext1
                    }
                }
            }
        }

        // ==== 日期格 ====
        MonthGrid {
            id: grid

            visible: !root.collapsed
            Layout.fillWidth: true
            Layout.preferredHeight: 170
            spacing: 0
            month: new Date().getMonth()
            year: new Date().getFullYear()
            locale: Qt.locale()

            delegate: Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.max(20, Math.min(parent.width, parent.height) * 0.8)
                    height: width
                    radius: width / 2
                    visible: model.today === true
                    color: Theme.blue
                }

                StyledText {
                    anchors.centerIn: parent
                    text: model.day ?? ""
                    color: model.today ? Theme.onPrimary : Theme.text
                    opacity: model.month === grid.month ? 1 : 0.35
                    font.pixelSize: 12
                    font.bold: model.today === true
                }
            }
        }
    }
}