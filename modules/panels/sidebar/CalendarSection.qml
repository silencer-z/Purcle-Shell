pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Configs
import qs.components
import qs.services

// 紧凑日历（可折叠）
PanelWidget {
    id: root

    property bool collapsed: false
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()

    // 当月格子：{ day, inMonth, today }
    readonly property var monthCells: {
        const first = new Date(root.viewYear, root.viewMonth, 1);
        const offset = (first.getDay() - Qt.locale().firstDayOfWeek + 7) % 7;
        const daysInMonth = new Date(root.viewYear, root.viewMonth + 1, 0).getDate();
        const daysInPrevMonth = new Date(root.viewYear, root.viewMonth, 0).getDate();
        const today = new Date();
        const cells = [];
        const total = Math.ceil((offset + daysInMonth) / 7) * 7;
        for (let i = 0; i < total; ++i) {
            const dayOffset = i - offset + 1;
            const inMonth = dayOffset >= 1 && dayOffset <= daysInMonth;
            const date = new Date(root.viewYear, root.viewMonth, dayOffset);
            cells.push({
                "day": inMonth ? dayOffset : (dayOffset < 1 ? daysInPrevMonth + dayOffset : dayOffset - daysInMonth),
                "inMonth": inMonth,
                "today": inMonth && date.toDateString() === today.toDateString()
            });
        }
        return cells;
    }

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

        // ==== 标题行 ====
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
                text: qsTr("%1 %2").arg(Qt.locale().monthName(root.viewMonth, Locale.LongFormat)).arg(root.viewYear)
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
                        const d = new Date(root.viewYear, root.viewMonth - 1, 1);
                        root.viewYear = d.getFullYear();
                        root.viewMonth = d.getMonth();
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
                        const d = new Date(root.viewYear, root.viewMonth + 1, 1);
                        root.viewYear = d.getFullYear();
                        root.viewMonth = d.getMonth();
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
                        root.viewYear = new Date().getFullYear();
                        root.viewMonth = new Date().getMonth();
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

                delegate: StyledText {
                    required property int index

                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.locale().dayName((Qt.locale().firstDayOfWeek + index) % 7, Locale.ShortFormat)
                    font.pixelSize: 11
                    font.bold: true
                    color: Theme.subtext1
                }
            }
        }

        // ==== 日期格 ====
        GridLayout {
            visible: !root.collapsed
            Layout.fillWidth: true
            Layout.preferredHeight: Math.ceil(root.monthCells.length / 7) * 26
            columns: 7
            columnSpacing: 0
            rowSpacing: 0

            Repeater {
                model: root.monthCells

                delegate: Item {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height) * 0.8
                        height: width
                        radius: width / 2
                        visible: modelData.today
                        color: Theme.blue
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: modelData.day
                        color: modelData.today ? Theme.onPrimary : Theme.text
                        opacity: modelData.inMonth ? 1 : 0.35
                        font.pixelSize: 12
                        font.bold: modelData.today
                    }
                }
            }
        }
    }
}
