import QtQuick
import QtQuick.Layouts
import qs.Configs
import qs.services

Text {
    property real fill: 0
    property real truncatedFill: Math.round(fill * 100) / 100
    property real size: Config.appearance.fonts.size.large

    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    color: Theme.text

    font {
        hintingPreference: Font.PreferFullHinting
        family: Config.appearance.fonts.family.material
        pixelSize: size
        weight: Font.Normal + (Font.DemiBold - Font.Normal) * fill
        variableAxes: {
            "FILL": truncatedFill,
            "opsz": size
        }
    }

}
