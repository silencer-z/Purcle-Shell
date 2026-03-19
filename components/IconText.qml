import QtQuick
import QtQuick.Layouts

Text {
    property real fill: 0
    property real truncatedFill: Math.round(fill * 100) / 100
    property real size: 16

    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    color: "#FFFFFF"

    font {
        hintingPreference: Font.PreferFullHinting
        family: "Material Symbols Rounded"
        pixelSize: size
        weight: Font.Normal + (Font.DemiBold - Font.Normal) * fill
        variableAxes: {
            "FILL": truncatedFill,
            "opsz": size
        }
    }

}
