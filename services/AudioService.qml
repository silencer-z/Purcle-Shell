pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root
    //筛选输入输出源
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


    PwObjectTracker {
        objects: [root.sink, root.source]
    }

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
}