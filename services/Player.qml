pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    // === 当前播放器 ===
    property MprisPlayer activePlayer: null
    property list<MprisPlayer> players: Mpris.players.values

    // === 播放器状态 ===
    readonly property bool isPlaying: !!activePlayer && activePlayer.isPlaying
    readonly property bool canPlay: !!activePlayer && activePlayer.canPlay
    readonly property bool canPause: !!activePlayer && activePlayer.canPause
    readonly property bool canTogglePlaying: !!activePlayer && activePlayer.canTogglePlaying
    readonly property bool canGoNext: !!activePlayer && activePlayer.canGoNext
    readonly property bool canGoPrevious: !!activePlayer && activePlayer.canGoPrevious

    // === 音量 / 循环 / 随机 支持 ===
    readonly property bool canChangeVolume: !!activePlayer && activePlayer.volumeSupported && activePlayer.canControl
    readonly property bool loopSupported: !!activePlayer && activePlayer.loopSupported && activePlayer.canControl
    readonly property bool shuffleSupported: !!activePlayer && activePlayer.shuffleSupported && activePlayer.canControl

    // === 曲目信息（只读） ===
    readonly property string trackTitle: activePlayer?.trackTitle ?? qsTr("Unknown Title")
    readonly property string trackArtist: activePlayer?.trackArtist ?? qsTr("Unknown Artist")
    readonly property string trackAlbum: activePlayer?.trackAlbum ?? qsTr("Unknown Album")
    readonly property string trackArtUrl: activePlayer?.trackArtUrl ?? ""
    readonly property string identity: activePlayer?.identity ?? qsTr("Unknown Player")

    readonly property bool hasPlayer: activePlayer !== null
    readonly property real position: activePlayer?.position ?? 0
    readonly property real length: activePlayer?.length ?? 0
    readonly property real progress: length > 0 ? position / length : 0
    readonly property bool canSeek: !!activePlayer && activePlayer.canSeek

    // === 信号 ===
    signal trackChanged(MprisPlayer player)
    signal playbackStateChanged(MprisPlayer player, bool playing)

    // === 播放控制 ===
    function play()       { if (activePlayer?.canPlay) activePlayer.play() }
    function pause()      { if (activePlayer?.canPause) activePlayer.pause() }
    function togglePlay() { if (activePlayer?.canTogglePlaying) activePlayer.togglePlaying() }
    function stop()       { activePlayer?.stop() }

    function next()       { if (activePlayer?.canGoNext) activePlayer.next() }
    function previous()   { if (activePlayer?.canGoPrevious) activePlayer.previous() }

    function seekTo(fraction: real): void {
        if (!activePlayer?.canSeek || length <= 0)
            return;
        activePlayer.position = Math.max(0, Math.min(length, fraction * length));
    }

    function refreshPosition(): void {
        activePlayer?.positionChanged();
    }

    // === 音量 / 循环 / 随机 ===
    function setVolume(v) { if (canChangeVolume) activePlayer.volume = v }
    function setLoopState(state) { if (loopSupported) activePlayer.loopState = state }
    function setShuffle(enabled) { if (shuffleSupported) activePlayer.shuffle = enabled }

    // === 主动切换播放器 ===
    function setActivePlayer(player: MprisPlayer) {
        if (activePlayer === player)
            return;
        activePlayer = player;
        trackChanged(player);
    }

    // === 自动跟踪播放中的播放器 ===
    Instantiator {
        model: Mpris.players

        Connections {
            required property MprisPlayer modelData
            target: modelData

            // 当一个播放器开始播放时自动成为 activePlayer
            function onPlaybackStateChanged() {
                if (modelData.isPlaying && root.activePlayer !== modelData)
                    root.setActivePlayer(modelData);
                root.playbackStateChanged(modelData, modelData.isPlaying);
            }

            function onTrackChanged() {
                if (root.activePlayer === modelData)
                    root.trackChanged(modelData);
            }

            Component.onCompleted: {
                if (!root.activePlayer)
                    root.setActivePlayer(modelData);
            }

            Component.onDestruction: {
                if (root.activePlayer === modelData) {
                    root.activePlayer = null;
                    const rest = Mpris.players.values;
                    if (rest && rest.length > 0)
                        root.setActivePlayer(rest[0]);
                }
            }
        }
    }

    onActivePlayerChanged: {
        if (activePlayer)
            console.log(`[Player] Active player: ${activePlayer.identity}`);
        else
            console.log("[Player] No active player");
    }
}