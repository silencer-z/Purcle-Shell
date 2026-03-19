import QtQuick
import Quickshell
import qs.components as Components

Components.BarWidget {
    id: root

    property string time: Qt.locale("en_US").toString(clock.date, "ddd hh:mm AP")

    color: "transparent"
    // padding:0
    paddingLeft: 0
    paddingRight: 0

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }

    Components.StyledText {
        anchors.fill: parent
        anchors.bottomMargin: 2
        font.pixelSize: 18
        text: time
    }

}
