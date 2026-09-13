import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    property bool colorize: false
    property color color
    property string source: ""
    property string iconFolder: Qt.resolvedUrl(Quickshell.shellPath("assets/apps")) // The folder to check first

    width: 30
    height: 30

    IconImage {
        id: iconImage

        anchors.fill: parent

        // 本地 assets/apps 优先；加载失败（文件不存在）时回退到 source 本身
        // failedSource 记录失败来源，root.source 变化时自动重试本地路径
        property string failedSource: ""

        source: failedSource === root.source ? root.source : iconFolder + "/" + root.source
        implicitSize: root.height

        onStatusChanged: {
            if (status === Image.Error)
                failedSource = root.source;
        }
    }

    Loader {
        active: root.colorize
        anchors.fill: iconImage

        sourceComponent: ColorOverlay {
            source: iconImage
            color: root.color
        }

    }

}
