pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.services

// 音量/亮度 OSD 调度：按屏幕显示，自动隐藏。
Singleton {
    id: root

    property string activeKind: ""
    property string activeScreenName: ""

    readonly property bool volumeVisible: root.activeKind === "volume"
    readonly property bool brightnessVisible: root.activeKind === "brightness"

    function show(kind: string, screenName: string): void {
        const name = screenName || HyprlandState.focusedMonitorName || Quickshell.screens[0]?.name || "";
        if (!name)
            return;
        root.activeKind = kind;
        root.activeScreenName = name;
        hideTimer.restart();
    }

    function hide(): void {
        hideTimer.stop();
        root.activeKind = "";
    }

    function isActiveOn(screenName: string): bool {
        return root.activeKind !== "" && root.activeScreenName === screenName;
    }

    Timer {
        id: hideTimer

        interval: 2000
        repeat: false
        onTriggered: root.activeKind = ""
    }

    Connections {
        id: volumeAudioConn

        ignoreUnknownSignals: true

        function onVolumeChanged(): void {
            root.show("volume", HyprlandState.focusedMonitorName);
        }

        function onMutedChanged(): void {
            root.show("volume", HyprlandState.focusedMonitorName);
        }
    }

    function bindVolumeAudio(): void {
        volumeAudioConn.target = Audio.sink?.audio ?? null;
    }

    Component.onCompleted: root.bindVolumeAudio()

    Connections {
        target: Pipewire

        function onDefaultAudioSinkChanged(): void {
            root.bindVolumeAudio();
        }
    }

    Connections {
        target: Brightness

        function onBrightnessChanged(): void {
            root.show("brightness", HyprlandState.focusedMonitorName);
        }
    }
}
