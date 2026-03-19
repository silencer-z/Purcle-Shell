import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.components

PanelWindow {
    id: root

    readonly property int stateClosed: 0
    readonly property int stateLoading: 1
    readonly property int stateOpen: 2
    readonly property int stateClosing: 3
    property int panelState: stateClosed

    property string contentComponent: ""
    readonly property bool hasCurrent: contentComponent !== ""

    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    mask: Region {
        x: panelFrame.x
        y: panelFrame.y
        width: panelFrame.width
        height: panelFrame.height
    }

    anchors.bottom:true
    anchors.left:true
    anchors.right:true
    anchors.top:true

    color: "transparent"
    visible: hasCurrent

    /* 使用状态机控制开启与关闭逻辑 */
    function open(sourceComponent, properties = {}) {
        switch (panelState) {
            case stateOpen:
                // 如果面板是开启的，那么就关闭它
                if (sourceComponent !== contentComponent) {
                    panelState = stateLoading;
                    contentComponent = sourceComponent;
                    var props = Object.assign({ panelWrapper: root }, properties);
                    contentLoader.setSource(sourceComponent, props);
                    
                }else{
                    root.close();
                }
                break;

            case stateClosed:
                // 如果面板是关闭的，那么就执行打开流程
                panelState = stateLoading;

                contentComponent = sourceComponent;
                var props = Object.assign({ panelWrapper: root }, properties);
                contentLoader.setSource(sourceComponent, props);
                grab.active = true;
                break;

            case stateLoading:
            case stateClosing:
                // 如果在处理过程中，则忽略这个请求
                // console.log("[NOTE]: Panel is busy, ignoring toggle request.")
                break;
        }
    }

    function close() {
        if (panelState !== stateOpen) {
            // console.log("[NOTE]: Panel is not open, ignoring close request.")
            return;
        }

        panelState = stateClosing;
        panelFrame.opened = false;

        // 先调用组件内部的销毁函数
        if (contentLoader.item && typeof contentLoader.item.close === "function") {
            contentLoader.item.close();
        }
        // 延迟销毁以保证动画执行
        Qt.callLater(() => Qt.createQmlObject(`
            import QtQuick 2.15; Timer { interval: 300; running: true; repeat: false; onTriggered: root.contentDestroy() }`,
            root, "DelayedClose")
        );
    }

    function contentDestroy() {
        contentComponent = "";
        contentLoader.source = "";
        panelState = stateClosed;
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        onCleared: root.close()
    }


    Item {
        id: panelFrame
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        property real panelRadius: 25 
        property bool opened: false 

        // 计算尺寸和执行动画
        implicitWidth: (contentLoader.item?.implicitWidth ?? 0) + panelRadius * 2 
        implicitHeight: opened ? (contentLoader.item?.implicitHeight ?? 0) : 0 
        clip: true 

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#80000000"
            radius: 16
            samples: radius * 2 // 提高阴影质量
            cached: true
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 250;
                easing.type: Easing.OutCubic 
            }
        }

        Rectangle {
            id: background
            z: -1 
            anchors.top: parent.top 
            anchors.left: parent.left 
            anchors.right: parent.right 
            anchors.leftMargin: panelFrame.panelRadius 
            anchors.rightMargin: panelFrame.panelRadius 
            height: parent.height + panelFrame.panelRadius 
            radius: panelFrame.panelRadius 
            color: "#1e1e2e" 
        }

        Loader {
            id: contentLoader
            active: root.hasCurrent
            asynchronous: true
            
            anchors.bottom: panelFrame.bottom 
            anchors.top: panelFrame.top 
            anchors.left: background.left 
            anchors.right: background.right 

            onStatusChanged: {
                if (status === Loader.Ready && panelState === stateLoading) {
                    panelState = stateOpen;
                    panelFrame.opened = true;
                }
            }
            onLoaded:{
                if (item && typeof item.init === "function") {
                    console.log("[INFO] Loader calling init()")
                    item.init()
                }
            }
        }

        RoundCorner {
            id: leftCorner
            anchors {
                bottom: parent.bottom 
                right: background.left 
            }
            size: panelFrame.panelRadius + 10 
            color: "#1e1e2e" 
            corner: RoundCorner.CornerEnum.BottomRight 
        }
        RoundCorner {
            id: rightCorner
            anchors {
                left: background.right 
                bottom: parent.bottom 
            }
            size: panelFrame.panelRadius + 10 
            color: "#1e1e2e" 
            corner: RoundCorner.CornerEnum.BottomLeft 
        }
    }
}