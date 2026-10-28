pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.Configs
import qs.services

// 把 Theme 语义色同步到 Hyprland / GTK / Qt / Zen。
// 预设与 matugen 共用同一条 apply 路径；其它应用暂不接入。
Singleton {
    id: root

    readonly property bool enabled: Config.colors.applySystem
    readonly property string applyScript: Paths.shellDir + "/assets/scripts/apply-system-theme.py"

    readonly property string paletteSig: {
        return [
            Theme.base, Theme.mantle, Theme.crust,
            Theme.surface0, Theme.surface1, Theme.surface2,
            Theme.text, Theme.subtext1, Theme.overlay0,
            Theme.mauve, Theme.blue, Theme.teal, Theme.lavender,
            Theme.red, Theme.onPrimary, Theme.shadow
        ].map(c => root.toHex(c)).join("") + (Theme.isDarkMode ? "d" : "l");
    }

    property bool _pendingRestart: false

    function toHex(c): string {
        const r = Math.round(c.r * 255).toString(16).padStart(2, "0");
        const g = Math.round(c.g * 255).toString(16).padStart(2, "0");
        const b = Math.round(c.b * 255).toString(16).padStart(2, "0");
        return `#${r}${g}${b}`;
    }

    function apply(): void {
        if (!root.enabled)
            return;
        const cmd = [
            "python3", root.applyScript,
            "--dark", Theme.isDarkMode ? "1" : "0",
            "--home", Paths.home,
            `base=${root.toHex(Theme.base)}`,
            `mantle=${root.toHex(Theme.mantle)}`,
            `crust=${root.toHex(Theme.crust)}`,
            `surface0=${root.toHex(Theme.surface0)}`,
            `surface1=${root.toHex(Theme.surface1)}`,
            `surface2=${root.toHex(Theme.surface2)}`,
            `text=${root.toHex(Theme.text)}`,
            `subtext1=${root.toHex(Theme.subtext1)}`,
            `overlay0=${root.toHex(Theme.overlay0)}`,
            `mauve=${root.toHex(Theme.mauve)}`,
            `blue=${root.toHex(Theme.blue)}`,
            `teal=${root.toHex(Theme.teal)}`,
            `lavender=${root.toHex(Theme.lavender)}`,
            `red=${root.toHex(Theme.red)}`,
            `onPrimary=${root.toHex(Theme.onPrimary)}`,
            `shadow=${root.toHex(Theme.shadow)}`
        ];
        applyProc.command = cmd;
        if (applyProc.running) {
            root._pendingRestart = true;
            applyProc.running = false;
            return;
        }
        applyProc.running = true;
    }

    onEnabledChanged: {
        if (root.enabled)
            applyTimer.restart();
    }
    onPaletteSigChanged: {
        if (root.enabled)
            applyTimer.restart();
    }
    Component.onCompleted: {
        if (root.enabled)
            applyTimer.restart();
    }

    Timer {
        id: applyTimer

        interval: 450
        repeat: false
        onTriggered: root.apply()
    }

    Process {
        id: applyProc

        stderr: SplitParser {
            onRead: line => console.warn("[system-theme]", line)
        }

        onExited: code => {
            if (root._pendingRestart) {
                root._pendingRestart = false;
                root.apply();
                return;
            }
            if (code !== 0)
                console.warn("[system-theme] apply failed, exit", code);
        }
    }
}
