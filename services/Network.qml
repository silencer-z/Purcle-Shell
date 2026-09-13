pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

// 参考 dots-hyprland / caelestia 的 nmcli 实现：
// 用 `nmcli monitor` 事件驱动刷新，避免轮询；区分 wifi 状态机与开关控制。
Singleton {
    id: root

    // ==== 连接状态 ====
    property bool wifi: false
    property bool ethernet: false
    property bool wifiEnabled: false
    // connected | connecting | disconnected | disabled | limited
    property string wifiStatus: "disconnected"
    property string networkName: ""
    property int networkStrength: 0
    property string activeWifiDevice: ""

    // ==== 可用网络 ====
    property bool isScanning: false
    property ListModel availableNetworks: ListModel {}
    property int availableNetworksCount: 0

    // ==== 连接中 / 失败 ====
    property string connectingSsid: ""
    signal connectFailed(string ssid)

    readonly property var cLocale: ({ LANG: "C", LC_ALL: "C" })

    property string materialSymbol: root.ethernet
        ? "lan"
        : root.wifiStatus === "connecting"
            ? "signal_wifi_statusbar_not_connected"
            : root.wifiStatus === "disabled"
                ? "signal_wifi_off"
                : root.wifiStatus === "limited"
                    ? "signal_wifi_bad"
                    : (root.networkName.length > 0 && root.networkName !== "lo")
                        ? (root.networkStrength > 80 ? "signal_wifi_4_bar" :
                           root.networkStrength > 60 ? "network_wifi_3_bar" :
                           root.networkStrength > 40 ? "network_wifi_2_bar" :
                           root.networkStrength > 20 ? "network_wifi_1_bar" :
                           "signal_wifi_0_bar")
                        : "wifi_find"

    // ==== 事件驱动：nmcli monitor 只在网络变化时触发 ====
    Process {
        id: subscriber

        running: true
        command: ["nmcli", "monitor"]
        environment: root.cLocale
        stdout: SplitParser {
            onRead: refreshDebounce.restart()
        }
    }

    // 兜底定时刷新（monitor 偶发漏事件时）
    Timer {
        id: fallbackTimer

        interval: 15000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: refreshDebounce

        interval: 250
        repeat: false
        onTriggered: root.refreshNow()
    }

    function refresh(): void {
        refreshDebounce.restart();
    }

    function refreshNow(): void {
        if (statusProc.running || networksProc.running) {
            refreshDebounce.restart();
            return;
        }
        statusProc.buffer = "";
        statusProc.running = true;
        networksProc.buffer = "";
        networksProc.running = true;
    }

    // ==== 设备类型 + 连接状态 + 连通性 ====
    Process {
        id: statusProc
        property string buffer: ""

        command: ["sh", "-c", "nmcli -t -f TYPE,STATE d status && nmcli -t -f CONNECTIVITY g"]
        environment: root.cLocale

        stdout: SplitParser {
            onRead: d => statusProc.buffer += d + "\n"
        }
        onExited: {
            const lines = statusProc.buffer.trim().split("\n");
            const connectivity = lines.pop() || "";
            let hasEthernet = false;
            let hasWifi = false;
            let wifiStatus = "disconnected";

            for (const line of lines) {
                if (line.includes("ethernet") && line.includes("connected"))
                    hasEthernet = true;
                else if (line.includes("wifi")) {
                    if (line.includes("connecting"))
                        wifiStatus = "connecting";
                    else if (line.includes("connected")) {
                        hasWifi = true;
                        wifiStatus = connectivity === "limited" ? "limited" : "connected";
                    } else if (line.includes("disconnected"))
                        wifiStatus = "disconnected";
                    else if (line.includes("unavailable"))
                        wifiStatus = "disabled";
                }
            }

            root.ethernet = hasEthernet;
            root.wifi = hasWifi;
            root.wifiStatus = wifiStatus;
            statusProc.buffer = "";
        }
    }

    // ==== 无线开关状态 ====
    Process {
        id: radioProc

        command: ["nmcli", "radio", "wifi"]
        environment: root.cLocale
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = text.trim() === "enabled"
        }
    }

    // ==== 当前连接名 ====
    Process {
        id: nameProc

        command: ["sh", "-c", "nmcli -t -f NAME c show --active | head -1"]
        environment: root.cLocale
        stdout: SplitParser {
            onRead: d => root.networkName = d.trim()
        }
    }

    // ==== 网络列表解析（SSID 中冒号转义处理） ====
    function parseNetworksText(text: string): void {
        const placeholder = "___QSCOLON___";
        const esc = new RegExp("\\\\:", "g");
        const unesc = new RegExp(placeholder, "g");
        const map = new Map();
        let activeStrength = 0;
        let activeSsid = "";

        for (const line of text.trim().split("\n")) {
            if (!line)
                continue;

            // -g ACTIVE,SIGNAL,SSID,SECURITY[,DEVICE]
            const cols = line.replace(esc, placeholder).split(":");
            if (cols.length < 3)
                continue;

            const active = cols[0] === "yes";
            const signal = parseInt(cols[1]);
            const ssid = (cols[2] || "").replace(unesc, ":");
            const security = cols.length > 3 ? (cols[3] || "--").replace(unesc, ":") : "--";
            const device = cols.length > 4 ? cols[4].replace(unesc, ":") : "";

            if (!ssid || isNaN(signal))
                continue;

            if (active) {
                activeStrength = signal;
                activeSsid = ssid;
                if (device)
                    root.activeWifiDevice = device;
            }

            const existing = map.get(ssid);
            if (!existing || signal > existing.signal)
                map.set(ssid, { ssid: ssid, signal: signal, security: security });
        }

        root.availableNetworks.clear();
        for (const n of map.values())
            root.availableNetworks.append(n);
        root.availableNetworksCount = root.availableNetworks.count;

        if (activeStrength > 0) {
            root.networkStrength = activeStrength;
            if (!root.networkName)
                root.networkName = activeSsid;
        }
    }

    Process {
        id: networksProc
        property string buffer: ""

        command: ["nmcli", "-g", "ACTIVE,SIGNAL,SSID,SECURITY,DEVICE", "device", "wifi"]
        environment: root.cLocale

        stdout: SplitParser {
            onRead: d => networksProc.buffer += d + "\n"
        }
        onExited: {
            root.parseNetworksText(networksProc.buffer);
            networksProc.buffer = "";
            if (!radioProc.running) radioProc.running = true;
            if (!nameProc.running) nameProc.running = true;
        }
    }

    // ==== 手动扫描（含 rescan） ====
    Process {
        id: scanProc
        property string buffer: ""

        command: ["sh", "-c", "nmcli -g ACTIVE,SIGNAL,SSID,SECURITY,DEVICE device wifi list --rescan yes"]
        environment: root.cLocale

        stdout: SplitParser {
            onRead: d => scanProc.buffer += d + "\n"
        }
        onExited: {
            root.isScanning = false;
            root.parseNetworksText(scanProc.buffer);
            scanProc.buffer = "";
        }
    }

    // ==== 控制 ====
    Process {
        id: enableWifiProc
    }

    Process {
        id: connectProc

        environment: root.cLocale
        stderr: SplitParser {
            onRead: line => {
                if (line.includes("Secrets were required") || line.includes("invalid password"))
                    root.connectFailed(root.connectingSsid);
            }
        }
        onExited: {
            root.connectingSsid = "";
            root.refresh();
        }
    }

    Process {
        id: disconnectProc

        environment: root.cLocale
        onExited: root.refresh()
    }

    function enableWifi(enabled: bool): void {
        enableWifiProc.exec(["nmcli", "radio", "wifi", enabled ? "on" : "off"]);
    }

    function toggleWifi(): void {
        root.enableWifi(!root.wifiEnabled);
    }

    function scanNetworks(): void {
        if (root.isScanning)
            return;
        root.isScanning = true;
        scanProc.buffer = "";
        scanProc.running = true;
    }

    function shellQuote(str: string): string {
        return "'" + str.replace(/'/g, `'\\''`) + "'";
    }

    function connectToNetwork(ssid: string, password: string): void {
        root.connectingSsid = ssid;
        const cmd = password && password !== ""
            ? `nmcli -w 10 device wifi connect ${root.shellQuote(ssid)} password ${root.shellQuote(password)}`
            : `nmcli -w 10 device wifi connect ${root.shellQuote(ssid)}`;
        connectProc.command = ["sh", "-c", cmd];
        connectProc.running = true;
    }

    function disconnectNetwork(): void {
        const dev = root.activeWifiDevice || "wlan0";
        const cmd = root.networkName
            ? `nmcli connection down ${root.shellQuote(root.networkName)}`
            : `nmcli -w 5 device disconnect ${dev}`;
        disconnectProc.command = ["sh", "-c", cmd];
        disconnectProc.running = true;
    }

    Component.onCompleted: {
        refresh();
        radioProc.running = true;
        nameProc.running = true;
    }
}
