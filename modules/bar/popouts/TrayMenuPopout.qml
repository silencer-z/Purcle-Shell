pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Configs
import qs.services

// 托盘菜单弹出面板：递归列表由 TrayMenuList 提供（Loader 按路径加载，新建文件无需重启注册）
Item {
    id: root

    property QsMenuHandle menu
    property var popouts: null

    readonly property int padding: Config.appearance.padding.normal

    implicitWidth: 240
    implicitHeight: (menuList.item?.implicitHeight ?? 0) + padding * 2

    Loader {
        id: menuList

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: Qt.resolvedUrl("TrayMenuList.qml")

        onLoaded: {
            item.width = root.width - root.padding * 2;
            item.menu = root.menu;
            item.popouts = root.popouts;
            item.depth = 0;
        }
    }
}