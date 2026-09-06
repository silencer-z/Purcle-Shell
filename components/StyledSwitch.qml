import QtQuick
import qs.Configs
import qs.services

// 主题化开关（Aylur 风格：checked = primary 填充）
Rectangle {
    id: root

    property bool checked: false
    property bool enabled: true
    signal toggled(bool checked)

    implicitWidth: 42
    implicitHeight: 24
    radius: 12
    color: checked ? Theme.mauve : Theme.surface2
    opacity: enabled ? 1 : 0.4

    Behavior on color {
        ColorAnim {}
    }

    Behavior on opacity {
        NumberAnim {
            duration: Config.appearance.animations.durations.small
        }
    }

    Rectangle {
        id: knob

        x: root.checked ? parent.width - width - 3 : 3
        anchors.verticalCenter: parent.verticalCenter
        width: 18
        height: 18
        radius: 9
        color: root.checked ? Theme.onPrimary : Theme.text

        Behavior on x {
            NumberAnim {}
        }

        Behavior on color {
            ColorAnim {}
        }
    }

    TapHandler {
        enabled: root.enabled
        onTapped: root.toggled(!root.checked)
    }
}
