pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // ==== 当前默认输出 / 输入 ====
    readonly property var nodes: Pipewire.nodes.values.reduce((acc, node) => {
        if (!node.isStream) {
            if (node.isSink)
                acc.sinks.push(node);
            else if (node.audio)
                acc.sources.push(node);
        }
        return acc;
    }, {
        sources: [],
        sinks: []
    })

    readonly property list<PwNode> sinks: nodes.sinks
    readonly property list<PwNode> sources: nodes.sources

    property bool ready: Pipewire.defaultAudioSink?.ready ?? false
    property PwNode sink: Pipewire.defaultAudioSink
    property PwNode source: Pipewire.defaultAudioSource

    readonly property bool muted: !!sink?.audio?.muted
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property int volumePercent: Math.round(root.volume * 100)

    readonly property bool sourceMuted: !!source?.audio?.muted
    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property int sourceVolumePercent: Math.round(root.sourceVolume * 100)

    // ==== 设备 / 应用节点列表 ====
    function correctType(node, isSink: bool): bool {
        return node.isSink === isSink && !!node.audio;
    }
    function devices(isSink: bool): var {
        return Pipewire.nodes.values.filter(node => root.correctType(node, isSink) && !node.isStream);
    }
    function appNodes(isSink: bool): var {
        return Pipewire.nodes.values.filter(node => root.correctType(node, isSink) && node.isStream);
    }
    readonly property list<var> outputDevices: root.devices(true)
    readonly property list<var> inputDevices: root.devices(false)
    readonly property list<var> outputAppNodes: root.appNodes(true)
    readonly property list<var> inputAppNodes: root.appNodes(false)

    function friendlyDeviceName(node): string {
        if (!node)
            return "Unknown";
        return node.nickname || node.description || node.name || "Unknown";
    }
    function appNodeDisplayName(node): string {
        if (!node)
            return "Unknown";
        return node.properties?.["application.name"] || node.description || node.name || "Unknown";
    }


    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    // ==== 控制 ====
    function setAudioSink(newSink: PwNode): void {
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setAudioSource(newSource: PwNode): void {
        Pipewire.preferredDefaultAudioSource = newSource;
    }

    function setVolume(percent: real): void {
        const v = Math.max(0, Math.min(1, percent));
        if (sink?.audio)
            sink.audio.volume = v;
    }

    function toggleMute(): void {
        if (sink?.audio)
            sink.audio.mute = !sink.audio.mute;
    }

    function toggleMicMute(): void {
        if (source?.audio)
            source.audio.mute = !source.audio.mute;
    }

    // 音量步长：低音量时更精细
    function volumeStep(): real {
        return root.volume < 0.1 ? 0.01 : 0.02;
    }

    function incrementVolume(): void {
        root.setVolume(root.volume + root.volumeStep());
    }

    function decrementVolume(): void {
        root.setVolume(root.volume - root.volumeStep());
    }
}
