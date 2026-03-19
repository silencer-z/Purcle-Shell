pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: trayPopup
    implicitWidth: 160
    implicitHeight: Math.max(40, listView.contentHeight + 12)
    visible: false
    color: "transparent"

    property QsMenuHandle menu
    property var anchorItem: null
    property real anchorX: 0
    property real anchorY: 0
    property int submenuGap: 12
    property var parentMenu: null

    anchor.item: anchorItem
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY

    function showAt(item, x, y) {
        if (!item) return;
        anchorItem = item;
        anchorX = x;
        anchorY = y;
        visible = true;
        // forceActiveFocus();
        Qt.callLater(() => trayPopup.anchor.updateAnchor());
    }

    function hideMenu() {
        visible = false;
        destroySubmenus();
    }

    function containsMouse() {
        return trayPopup.containsMouse;
    }

    function destroySubmenus() {
        if (!listView.contentItem.children) return;
        for (let child of listView.contentItem.children) {
            if (child.subMenu) {
                child.subMenu.hideMenu();
                child.subMenu.destroy();
                child.subMenu = null;
            }
        }
    }

    function openSubmenu(entry, modelData) {
        destroySubmenus();

        // 计算位置
        var globalPos = entry.mapToGlobal(0, 0);
        var submenuWidth = implicitWidth;
        var openLeft = (globalPos.x + entry.width + submenuWidth > Screen.width);
        var offsetX = openLeft ? -submenuWidth - submenuGap : entry.width + submenuGap;

        // 使用 Qt.createComponent 创建新的 TrayPopup
        var comp = Qt.createComponent("TrayPopup.qml");
        if (comp.status === Component.Ready) {
            entry.subMenu = comp.createObject(trayPopup, {
                menu: modelData,
                anchorItem: entry,
                anchorX: offsetX,
                anchorY: 0,
                parentMenu: trayPopup
            });
            entry.subMenu.showAt(entry, offsetX, 0);
        } else {
            console.error("Failed to create submenu component");
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        border.color: "#cba6f7"
        border.width: 1
        radius: 12
    }

    QsMenuOpener {
        id: opener;
        menu: trayPopup.menu;
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 6
        spacing: 2
        interactive: false
        enabled: trayPopup.visible
        clip: true

        model: ScriptModel {
            values: opener.children ? [...opener.children.values] : []
        }

        delegate: Rectangle {
            id: entry
            required property var modelData
            property var subMenu: null

            width: listView.width
            height: (modelData?.isSeparator) ? 6 : 28
            color: "transparent"
            radius: 12

            // 分隔线
            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 20
                height: 2
                color: "#585b70"
                visible: modelData?.isSeparator ?? false
            }

            // 背景和内容
            Rectangle {
                id: bg
                anchors.fill: parent
                color: mouseArea.containsMouse ? "#cba6f7" : "transparent"
                radius: 8
                visible: !(modelData?.isSeparator ?? false)
                property color hoverTextColor: mouseArea.containsMouse ? "#FFFFFF" : "#cdd6f4"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        color: (modelData?.enabled ?? true) ? bg.hoverTextColor : "#585b70"
                        text: modelData?.text ?? ""
                        font.family: "更纱终端书呆简体-黑"
                        font.pixelSize: 16
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    Image {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        source: modelData?.icon ?? ""
                        visible: (modelData?.icon ?? "") !== ""
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: modelData?.hasChildren ? "menu" : ""
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 16
                        verticalAlignment: Text.AlignVCenter
                        visible: modelData?.hasChildren ?? false
                        color: "#cdd6f4"
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false) && trayPopup.visible

                    onClicked: {
                        if (!modelData?.isSeparator) {
                            if (modelData?.hasChildren) return;
                            modelData.triggered();
                            trayPopup.hideMenu();
                        }
                    }

                    onEntered: {
                        if (!trayPopup.visible) return;
                        if (modelData?.hasChildren) {
                            trayPopup.openSubmenu(entry, modelData);
                        } else {
                            trayPopup.destroySubmenus(listView);
                        }
                    }

                    onExited: {
                        if (subMenu && !subMenu.containsMouse()) {
                            subMenu.hideMenu();
                            subMenu.destroy();
                            subMenu = null;
                        }
                    }
                }
            }

            function containsMouse() {
                return mouseArea.containsMouse;
            }

            Component.onDestruction: {
                if (subMenu) {
                    subMenu.destroy();
                    subMenu = null;
                }
            }
        }
    }
}
