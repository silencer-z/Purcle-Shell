pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Configs
import qs.services
import qs.components

// 托盘菜单列表（可自引用嵌套渲染子菜单，accordion 展开）
Column {
    id: list

    property QsMenuHandle menu: null
    property var popouts: null
    property int indent: 0
    property int depth: 0

    readonly property int rowRadius: 8
    readonly property int itemHeight: 32
    readonly property int maxDepth: 5

    spacing: 2
    leftPadding: indent

    QsMenuOpener {
        id: opener

        menu: list.menu
    }

    Repeater {
        model: ScriptModel {
            values: opener.children ? [...opener.children.values] : []
        }

        Column {
            id: entry

            required property QsMenuHandle modelData

            property bool expanded: false

            width: list.width - list.indent
            spacing: 2

            Rectangle {
                width: entry.width
                height: (entry.modelData?.isSeparator ?? false) ? 6 : list.itemHeight
                radius: list.rowRadius
                color: rowArea.containsMouse && !(entry.modelData?.isSeparator ?? false) ? Theme.surface1 : "transparent"

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 24
                    height: 1
                    color: Theme.surface2
                    visible: entry.modelData?.isSeparator ?? false
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    visible: !(entry.modelData?.isSeparator ?? false)

                    StyledText {
                        Layout.fillWidth: true
                        text: entry.modelData?.text ?? ""
                        color: (entry.modelData?.enabled ?? true) ? Theme.text : Theme.overlay0
                        font.pixelSize: Config.appearance.fonts.size.medium
                        elide: Text.ElideRight
                    }

                    Image {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        source: entry.modelData?.icon ?? ""
                        visible: (entry.modelData?.icon ?? "") !== ""
                        fillMode: Image.PreserveAspectFit
                    }

                    MaterialSymbol {
                        text: entry.expanded ? "keyboard_arrow_up" : "keyboard_arrow_down"
                        size: 16
                        color: Theme.overlay0
                        visible: entry.modelData?.hasChildren ?? false
                    }
                }

                MouseArea {
                    id: rowArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: (entry.modelData?.enabled ?? true) && !(entry.modelData?.isSeparator ?? false)

                    onClicked: {
                        if (entry.modelData?.hasChildren) {
                            entry.expanded = !entry.expanded;
                            return;
                        }
                        entry.modelData?.triggered();
                        list.popouts?.close();
                    }
                }
            }

            Loader {
                active: entry.expanded && (entry.modelData?.hasChildren ?? false) && list.depth < list.maxDepth
                visible: active
                width: entry.width
                source: Qt.resolvedUrl("TrayMenuList.qml")

                onLoaded: {
                    item.menu = entry.modelData;
                    item.popouts = list.popouts;
                    item.indent = 14;
                    item.depth = list.depth + 1;
                }
            }
        }
    }
}