pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Configs
import qs.services
import qs.components

// 音量 + 亮度 + 输出/输入设备（caelestia AudioPopout 结构 + Aylur sliders-box 语言）
Item {
    id: root

    readonly property int padding: Config.appearance.padding.normal
    readonly property int rowRadius: 10
    readonly property var focusedMonitor: {
        const name = Hyprland.focusedMonitor.name;
        return Brightness.monitors.find(m => m.screen.name === name) ?? null;
    }

    implicitWidth: 320
    implicitHeight: layout.implicitHeight + padding * 2

    ColumnLayout {
        id: layout

        anchors.centerIn: parent
        width: parent.width - root.padding * 2
        spacing: Config.appearance.spacing.smaller

        StyledText {
            text: "输出设备"
            color: Theme.overlay0
            font.pixelSize: 11
        }

        Repeater {
            model: Audio.sinks

            PopoutRadioRow {
                Layout.fillWidth: true
                checked: Audio.sink?.id === modelData.id
                label: Audio.friendlyDeviceName(modelData)
                onClicked: Audio.setAudioSink(modelData)
            }
        }

        StyledText {
            text: "输入设备"
            color: Theme.overlay0
            font.pixelSize: 11

            Layout.topMargin: Config.appearance.spacing.small
        }

        Repeater {
            model: Audio.sources

            PopoutRadioRow {
                Layout.fillWidth: true
                checked: Audio.source?.id === modelData.id
                label: Audio.friendlyDeviceName(modelData)
                onClicked: Audio.setAudioSource(modelData)
            }
        }

        PopoutSliderRow {
            icon: Audio.muted || Audio.volume <= 0 ? "volume_off" : Audio.volume >= 0.5 ? "volume_up" : "volume_down"
            iconColor: Theme.blue
            value: Audio.volume
            valueText: Audio.volumePercent + "%"
            muted: Audio.muted

            Layout.fillWidth: true
            Layout.topMargin: Config.appearance.spacing.small

            onIconClicked: Audio.toggleMute()
            onSliderEdited: v => Audio.setVolume(v)
            onWheel: delta => Audio.setVolume(Audio.volume + delta * 0.02)
        }

        PopoutSliderRow {
            icon: root.focusedMonitor?.iconName ?? "brightness_6"
            iconColor: Theme.yellow
            value: root.focusedMonitor?.brightness ?? 0
            valueText: Math.round((root.focusedMonitor?.brightness ?? 0) * 100) + "%"

            Layout.fillWidth: true

            onSliderEdited: v => root.focusedMonitor?.setBrightness(Math.max(0.01, Math.min(1, v)))
            onWheel: delta => {
                if (root.focusedMonitor)
                    root.focusedMonitor.setBrightness(Math.max(0.01, Math.min(1, root.focusedMonitor.brightness + delta * 0.05)));
            }
        }
    }

    component PopoutRadioRow: Rectangle {
        id: radioRow

        required property var modelData

        property bool checked: false
        property string label: ""
        signal clicked()

        implicitHeight: 34
        radius: root.rowRadius
        color: checked ? Theme.mauve : hoverHandler.hovered ? Theme.surface1 : Theme.surface0

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
                size: 16
                color: radioRow.checked ? Theme.onPrimary : Theme.overlay0
            }

            StyledText {
                Layout.fillWidth: true
                text: radioRow.label
                color: radioRow.checked ? Theme.onPrimary : Theme.text
                font.pixelSize: 13
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

    component PopoutSliderRow: Rectangle {
        id: sliderRow

        property string icon: ""
        property color iconColor: Theme.blue
        property bool muted: false
        property real value: 0
        property string valueText: ""
        signal iconClicked()
        signal sliderEdited(real v)
        signal wheel(real delta)

        implicitHeight: 40
        radius: root.rowRadius
        color: Theme.surface0

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Item {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: sliderRow.icon
                    size: 20
                    color: sliderRow.muted ? Theme.overlay0 : sliderRow.iconColor
                }

                TapHandler {
                    onTapped: sliderRow.iconClicked()
                }
            }

            StyledSlider {
                id: slider

                Layout.fillWidth: true
                Layout.preferredHeight: 20
                value: sliderRow.value
                configuration: StyledSlider.Configuration.S
                highlightColor: sliderRow.iconColor
                trackColor: Theme.surface1
                handleColor: sliderRow.iconColor

                onValueChanged: {
                    if (pressed)
                        sliderRow.sliderEdited(value);
                }

                onMoved: {
                    sliderRow.sliderEdited(value);
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    propagateComposedEvents: true

                    onWheel: wheel => {
                        sliderRow.wheel(wheel.angleDelta.y > 0 ? 1 : -1);
                        wheel.accepted = true;
                    }
                }
            }

            StyledText {
                text: sliderRow.valueText
                color: Theme.subtext1
                font.pixelSize: 12
            }
        }
    }
}