pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Io

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

    // === 音量 / 循环 / 随机 ===
    function setVolume(v) { if (canChangeVolume) activePlayer.volume = v }
    function setLoopState(state) { if (loopSupported) activePlayer.loopState = state }
    function setShuffle(enabled) { if (shuffleSupported) activePlayer.shuffle = enabled }

    // === 主动切换播放器 ===
    function setActivePlayer(player: MprisPlayer) {
        if (activePlayer === player)
            return;
        activePlayer = player;
        activePlayerChanged();
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
                    // 选一个仍存在的播放器
                    if (Mpris.players.count > 0)
                        root.setActivePlayer(Mpris.players[0]);
                }
            }
        }
    }

    onActivePlayerChanged: {
        if (activePlayer)
            console.log(`[MprisService] Active player: ${activePlayer.identity}`);
        else
            console.log("[MprisService] No active player");
    }
}