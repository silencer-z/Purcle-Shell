import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

import qs.components as Components

Components.BarWidget {

    id:root
    property bool trayExpanded: false

    paddingLeft:0
    paddingRight:0

    color:"transparent"
    implicitWidth:trayExpanded ? rowLayout.implicitWidth + 5 : toggleBtn.width

    HyprlandFocusGrab {
        id: grab
        windows: [trayMenu]
        onCleared: {
            trayMenu.hideMenu();
        }
    }

    RowLayout {
        id:rowLayout

        spacing: 1
        anchors.fill:parent
        layoutDirection:Qt.RightToLeft
        property bool containsMouse: false

        Rectangle {
            id: toggleBtn
            Layout.preferredWidth: arrowIcon.width
            Layout.preferredHeight: parent.height
            color: toggleBtnMouseArea.containsMouse ? "#11c1c1c1" : "transparent"
            radius: 5

            MouseArea {
                id: toggleBtnMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.trayExpanded = !root.trayExpanded;
                }
            }

            Text {
                id: arrowIcon
                anchors.centerIn: parent
                text: "◀"
                color: "#cdd6f4"
                font.pixelSize: 12
                rotation: root.trayExpanded ? 180 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        Item{
            clip: true
            Layout.preferredHeight: parent.height
            Layout.preferredWidth:trayMask.width
            Layout.minimumWidth: 1
            Layout.minimumHeight: parent.height
            Item{
                id:trayMask
                width: root.trayExpanded ? trayRow.implicitWidth + 10 : 2
                height: parent.height

                Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                
                Row{
                    id:trayRow
                    anchors.fill: parent
                    height: 20
                    spacing:7

                    Repeater {
                        id:sysTray
                        
                        model: SystemTray.items
                        MouseArea {
                            id: delegate
                            required property SystemTrayItem modelData
                            property alias item: delegate.modelData

                            width:trayIcon.implicitWidth + 3
                            height:parent.height
                            enabled:root.trayExpanded

                            Layout.fillHeight: true

                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                            onClicked: mouse => {
                                /* 托盘菜单还是需要点击启动的 */
                                if (!modelData)
                                    return;
                                if (mouse.button === Qt.LeftButton) {
                                    // Close any open menu first
                                    if (trayMenu && trayMenu.visible) {
                                        trayMenu.hideMenu();
                                    }
                                    if (!modelData.onlyMenu) {
                                        modelData.activate();
                                    }
                                } else if (mouse.button === Qt.MiddleButton) {
                                    // Close any open menu first
                                    if (trayMenu && trayMenu.visible) {
                                        trayMenu.hideMenu();
                                    }
                                    modelData.secondaryActivate && modelData.secondaryActivate();

                                } else if (mouse.button === Qt.RightButton) {
                                    // If menu is already visible, close it
                                    if (trayMenu && trayMenu.visible) {
                                        trayMenu.hideMenu();
                                        return;
                                    }

                                    if (modelData.hasMenu && modelData.menu && trayMenu) {
                                        // Anchor the menu to the tray icon item (parent) and position it below the icon
                                        const menuX = (width / 2) - (trayMenu.width / 2);
                                        const menuY = height + 15;
                                        trayMenu.menu = modelData.menu;
                                        trayMenu.showAt(parent, menuX, menuY);
                                        grab.active=true
                                    } else
                                    {
                                    console.log("No menu available for", modelData.id, "or trayMenu not set")
                                    }
                                }
                            }
                            IconImage {
                                id: trayIcon
                                asynchronous: true
                                backer.fillMode: Image.PreserveAspectFit
                                source: {
                                    let icon = modelData?.icon || "";
                                    if (!icon)
                                        return "";
                                    if (icon.includes("?path=")) {
                                        const [name, path] = icon.split("?path=");
                                        const fileName = name.substring(name.lastIndexOf("/") + 1);
                                        return `file://${path}/${fileName}`;
                                    }
                                    return icon;
                                }
                                anchors.centerIn: parent
                                implicitSize: 20
                                opacity: status === Image.Ready ? 1 : 0
                            }
                        }
                    }
                }
            }
        }

    }

    TrayPopup{
        id:trayMenu
    }
}

