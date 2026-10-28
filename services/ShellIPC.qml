pragma Singleton

import Quickshell
import Quickshell.Io
import qs.services

// qs ipc call 入口：qs ipc call panels toggle launcher
//                  qs ipc call volume set 50
Singleton {
    id: root

    IpcHandler {
        target: "panels"

        function toggle(name: string): void {
            Visibilities.togglePanel(name);
        }

        function open(name: string): void {
            Visibilities.hideAll();
            if (name === "launcher")
                Visibilities.launcher = true;
            else if (name === "clipboard")
                Visibilities.clipboard = true;
            else if (name === "wallpaper")
                Visibilities.wallpaper = true;
            else if (name === "sidebar")
                Visibilities.sidebar = true;
            else if (name === "task")
                Visibilities.task = true;
        }

        function close(name: string): void {
            if (name === "launcher")
                Visibilities.launcher = false;
            else if (name === "clipboard")
                Visibilities.clipboard = false;
            else if (name === "wallpaper")
                Visibilities.wallpaper = false;
            else if (name === "sidebar")
                Visibilities.sidebar = false;
            else if (name === "task")
                Visibilities.task = false;
            else
                Visibilities.hideAll();
        }

        function hideAll(): void {
            Visibilities.hideAll();
        }
    }

    IpcHandler {
        target: "volume"

        function get(): string {
            return JSON.stringify({
                volume: Audio.volume,
                muted: Audio.muted,
                percent: Audio.volumePercent
            });
        }

        function set(percent: int): void {
            Audio.setVolume(percent / 100);
        }

        function change(delta: int): void {
            Audio.setVolume(Math.max(0, Math.min(1, Audio.volume + delta / 100)));
        }

        function toggleMute(): void {
            Audio.toggleMute();
        }
    }

    IpcHandler {
        target: "brightness"

        function get(): string {
            const m = Brightness.focusedMonitor;
            return JSON.stringify({
                brightness: m?.brightness ?? 0,
                percent: Math.round((m?.brightness ?? 0) * 100)
            });
        }

        function set(percent: int): void {
            if (Brightness.focusedMonitor)
                Brightness.focusedMonitor.setBrightness(percent / 100);
        }

        function change(delta: int): void {
            if (Brightness.focusedMonitor) {
                const m = Brightness.focusedMonitor;
                m.setBrightness(Math.max(0, Math.min(1, m.brightness + delta / 100)));
            }
        }
    }

    IpcHandler {
        target: "wallpaper"

        function get(): string {
            return Wallpapers.currentWallpaper || "";
        }

        function set(path: string): void {
            Wallpapers.setWallpaper(path);
        }

        function random(): void {
            Wallpapers.setRandom();
        }
    }

    IpcHandler {
        target: "player"

        function toggle(): void {
            Player.togglePlay();
        }

        function next(): void {
            Player.next();
        }

        function previous(): void {
            Player.previous();
        }

        function status(): string {
            return JSON.stringify({
                title: Player.trackTitle,
                artist: Player.trackArtist,
                playing: Player.isPlaying,
                identity: Player.identity
            });
        }
    }
}
