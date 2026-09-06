pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Configs
import qs.services
import qs.components

// 电池弹出面板：大字百分比 + 电量进度条 + 预计时间 / 功耗
Item {
    id: root

    readonly property int padding: Config.appearance.padding.normal
    readonly property int rowRadius: 10

    readonly property color levelColor: Battery.isCritical ? Theme.danger : Battery.isLow ? Theme.warning : Battery.isCharging ? Theme.green : Theme.mauve

    readonly property string timeText: {
        if (!Battery.available)
            return "";
        if (Battery.isCharging && Battery.timeToFull > 0) {
            const h = Math.floor(Battery.timeToFull / 3600);
            const m = Math.floor((Battery.timeToFull % 3600) / 60);
            return h > 0 ? `${h}小时${m}分后充满` : `${m}分后充满`;
        }
        if (!Battery.isPluggedIn && Battery.timeToEmpty > 0) {
            const h = Math.floor(Battery.timeToEmpty / 3600);
            const m = Math.floor((Battery.timeToEmpty % 3600) / 60);
            return h > 0 ? `${h}小时${m}分后用尽` : `${m}分后用尽`;
        }
        return "";
    }

    implicitWidth: 260
    implicitHeight: column.implicitHeight + padding * 2

    ColumnLayout {
        id: column

        anchors.centerIn: parent
        width: parent.width - root.padding * 2
        spacing: Config.appearance.spacing.normal

        // ==== 头部：图标 + 百分比 + 状态 ====
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            MaterialSymbol {
                text: Battery.iconName()
                size: 36
                color: root.levelColor

                Behavior on color {
                    ColorAnim {}
                }
            }

            ColumnLayout {
                spacing: 0

                StyledText {
                    text: Math.round(Battery.percentage * 100) + "%"
                    color: Theme.text
                    font.pixelSize: 26
                    font.bold: true
                }

                StyledText {
                    text: !Battery.available ? qsTr("未检测到电池") : Battery.isCharging ? qsTr("正在充电") : Battery.isPluggedIn ? qsTr("已接通电源") : qsTr("使用电池")
                    color: Theme.subtext1
                    font.pixelSize: 12
                }
            }

            Item {
                Layout.fillWidth: true
            }

            // 充电动效标记
            MaterialSymbol {
                visible: Battery.isCharging
                text: "bolt"
                size: 18
                color: Theme.green

                Behavior on opacity {
                    NumberAnim {
                        duration: Config.appearance.animations.durations.large
                    }
                }

                // 呼吸闪烁
                SequentialAnimation on opacity {
                    running: Battery.isCharging
                    loops: Animation.Infinite

                    NumberAnimation {
                        from: 1
                        to: 0.3
                        duration: Config.appearance.animations.durations.large
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Config.appearance.animations.curves.standard
                    }
                    NumberAnimation {
                        from: 0.3
                        to: 1
                        duration: Config.appearance.animations.durations.large
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Config.appearance.animations.curves.standard
                    }
                }
            }
        }

        // ==== 电量进度条 ====
        StyledProgressBar {
            Layout.fillWidth: true
            value: Battery.percentage
            highlightColor: root.levelColor
            trackColor: Theme.surface0
            valueBarHeight: 6
            showEndCap: false
        }

        // ==== 详情：预计时间 / 功耗 / 健康度 ====
        Rectangle {
            visible: root.timeText !== "" || Battery.energyRate !== 0 || Battery.health > 0
            Layout.fillWidth: true
            implicitHeight: detail.implicitHeight + 14
            radius: root.rowRadius
            color: Theme.surface0

            ColumnLayout {
                id: detail

                anchors.centerIn: parent
                width: parent.width - 20
                spacing: 4

                Repeater {
                    model: {
                        const rows = [];
                        if (root.timeText !== "")
                            rows.push({ label: qsTr("预计"), value: root.timeText });
                        if (Battery.energyRate !== 0)
                            rows.push({ label: qsTr("功耗"), value: `${Math.abs(Battery.energyRate).toFixed(1)} W` });
                        if (Battery.health > 0)
                            rows.push({ label: qsTr("健康度"), value: `${Math.round(Battery.health)}%` });
                        return rows;
                    }

                    delegate: RowLayout {
                        id: detailRow

                        required property var modelData

                        Layout.fillWidth: true
                        spacing: 8

                        StyledText {
                            text: detailRow.modelData.label
                            color: Theme.overlay0
                            font.pixelSize: 11
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: detailRow.modelData.value
                            color: Theme.subtext1
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}
