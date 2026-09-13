pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Configs
import qs.components
import qs.services

// 滑块区：音量 + 亮度
PanelWidget {
    id: root

    property bool devicesExpanded: false

    color: Theme.surface0

    Behavior on color {
        ColorAnim {}
    }

    implicitHeight: rows.implicitHeight + Config.appearance.padding.normal * 2

    ColumnLayout {
        id: rows

        anchors.fill: parent
        spacing: Config.appearance.spacing.small

        // ==== 音量行 ====
        RowLayout {
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small

            MaterialSymbol {
                text: Audio.muted || Audio.volume <= 0 ? "volume_off" : Audio.volume >= 0.5 ? "volume_up" : "volume_down"
                size: 18
                color: Theme.blue

                TapHandler {
                    onTapped: Audio.toggleMute()
                }
            }

            StyledSlider {
                Layout.fillWidth: true
                Layout.preferredHeight: 18
                value: Audio.volume
                configuration: StyledSlider.Configuration.S
                highlightColor: Theme.blue
                trackColor: Theme.surface1
                handleColor: Theme.blue

                onValueChanged: {
                    if (pressed)
                        Audio.setVolume(value);
                }

                onMoved: Audio.setVolume(value)

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    propagateComposedEvents: true

                    onWheel: wheel => {
                        Audio.setVolume(Audio.volume + (wheel.angleDelta.y > 0 ? 0.02 : -0.02));
                        wheel.accepted = true;
                    }
                }
            }

            StyledText {
                Layout.preferredWidth: 34
                text: Audio.volumePercent + "%"
                color: Theme.subtext1
                font.pixelSize: 11
                horizontalAlignment: Text.AlignRight
            }

            // 展开/收起音频设备列表
            MaterialSymbol {
                text: root.devicesExpanded ? "keyboard_arrow_up" : "tune"
                size: 16
                color: root.devicesExpanded ? Theme.mauve : Theme.overlay0

                Behavior on color {
                    ColorAnim {}
                }

                TapHandler {
                    onTapped: root.devicesExpanded = !root.devicesExpanded
                }
            }
        }

        // ==== 音频设备展开区 ====
        ColumnLayout {
            visible: root.devicesExpanded
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small / 2

            // 隐式高度动画
            Behavior on implicitHeight {
                NumberAnim {}
            }

            StyledText {
                text: qsTr("输出设备")
                color: Theme.overlay0
                font.pixelSize: 10
            }

            Repeater {
                model: Audio.sinks

                DeviceRadioRow {
                    Layout.fillWidth: true
                    checked: Audio.sink?.id === modelData.id
                    label: Audio.friendlyDeviceName(modelData)
                    onClicked: Audio.setAudioSink(modelData)
                }
            }

            StyledText {
                text: qsTr("输入设备")
                color: Theme.overlay0
                font.pixelSize: 10

                Layout.topMargin: Config.appearance.spacing.small / 2
            }

            Repeater {
                model: Audio.sources

                DeviceRadioRow {
                    Layout.fillWidth: true
                    checked: Audio.source?.id === modelData.id
                    label: Audio.friendlyDeviceName(modelData)
                    onClicked: Audio.setAudioSource(modelData)
                }
            }
        }

        // ==== 亮度行 ====
        RowLayout {
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small

            MaterialSymbol {
                text: Brightness.focusedMonitor?.iconName ?? "brightness_6"
                size: 18
                color: Theme.yellow
            }

            StyledSlider {
                Layout.fillWidth: true
                Layout.preferredHeight: 18
                value: Brightness.focusedMonitor?.brightness ?? 0.5
                enabled: Brightness.focusedMonitor !== null
                configuration: StyledSlider.Configuration.S
                highlightColor: Theme.yellow
                trackColor: Theme.surface1
                handleColor: Theme.yellow

                onValueChanged: {
                    if (pressed && Brightness.focusedMonitor)
                        Brightness.focusedMonitor.setBrightness(Math.max(0.01, Math.min(1, value)));
                }

                onMoved: {
                    if (Brightness.focusedMonitor)
                        Brightness.focusedMonitor.setBrightness(Math.max(0.01, Math.min(1, value)));
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    propagateComposedEvents: true

                    onWheel: wheel => {
                        if (!Brightness.focusedMonitor)
                            return;
                        const b = Brightness.focusedMonitor.brightness + (wheel.angleDelta.y > 0 ? 0.05 : -0.05);
                        Brightness.focusedMonitor.setBrightness(Math.max(0.01, Math.min(1, b)));
                        wheel.accepted = true;
                    }
                }
            }

            StyledText {
                Layout.preferredWidth: 34
                text: Math.round((Brightness.focusedMonitor?.brightness ?? 0) * 100) + "%"
                color: Theme.subtext1
                font.pixelSize: 11
                horizontalAlignment: Text.AlignRight
            }

            // 占位与音量行的展开图标对齐
            Item {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
            }
        }
    }

    // 音频设备单选行
    component DeviceRadioRow: Rectangle {
        id: radioRow

        required property var modelData

        property bool checked: false
        property string label: ""
        signal clicked()

        implicitHeight: 30
        radius: 8
        color: checked ? Theme.mauve : hoverHandler.hovered ? Theme.surface1 : "transparent"

        Behavior on color {
            ColorAnim {}
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            MaterialSymbol {
                text: radioRow.checked ? "radio_button_checked" : "radio_button_unchecked"
                size: 14
                color: radioRow.checked ? Theme.onPrimary : Theme.overlay0
            }

            StyledText {
                Layout.fillWidth: true
                text: radioRow.label
                color: radioRow.checked ? Theme.onPrimary : Theme.text
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }

        HoverHandler {
            id: hoverHandler
        }

        TapHandler {
            onTapped: radioRow.clicked()
        }
    }
}
