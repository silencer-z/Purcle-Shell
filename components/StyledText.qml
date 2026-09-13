// 统一设计风格
import QtQuick
import qs.Configs
import qs.services

Text {
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    color: Theme.text

    font {
        hintingPreference: Font.PreferFullHinting
        family: Config.appearance.fonts.family.sans
        pixelSize: Config.appearance.fonts.size.normal
    }
}
