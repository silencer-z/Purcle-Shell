pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick


Singleton {
    id: root

    property bool wifi: false
    property bool ethernet: false
    property int updateInterval: 5000
    property string networkName: ""
    property int networkStrength: 0
    property string activeWifiDevice: ""

    property string materialSymbol: root.ethernet ? "lan" :
        (root.networkName.length > 0 && root.networkName !== "lo") ? (
            root.networkStrength > 80 ? "signal_wifi_4_bar" :
            root.networkStrength > 60 ? "network_wifi_3_bar" :
            root.networkStrength > 40 ? "network_wifi_2_bar" :
            root.networkStrength > 20 ? "network_wifi_1_bar" :
            "signal_wifi_0_bar"
        ) : "signal_wifi_off"

    Timer {
        id: pollTimer

        interval: root.updateInterval
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    function refresh() {
        statusProc.running = true;
        signalProc.running = true;
    }

    // ---- 活动连接：名称 + 类型 ----
    Process {
        id: statusProc
        property string buffer: ""

        command: ["sh", "-c", "nmcli -t -f NAME,TYPE c show --active"]

        stdout: SplitParser {
            onRead: data => {
                statusProc.buffer += data + "\n";
            }
        }
        onExited: {
            const lines = statusProc.buffer.trim().split('\n');
            let hasEthernet = false;
            let hasWifi = false;
            let firstName = "";
            let wifiName = "";
            lines.forEach(line => {
                const idx = line.indexOf(':');
                if (idx === -1)
                    return;
                const connName = line.slice(0, idx);
                const type = line.slice(idx + 1);
                if (type.includes("ethernet")) {
                    hasEthernet = true;
                    if (!firstName)
                        firstName = connName;
                } else if (type.includes("wireless")) {
                    hasWifi = true;
                    if (!wifiName)
                        wifiName = connName;
                }
            });
            root.ethernet = hasEthernet;
            root.wifi = hasWifi;
            root.networkName = wifiName || firstName || "";
            statusProc.buffer = "";
        }
    }

    // ---- 活动 WiFi 信号强度 + 设备名 ----
    Process {
        id: signalProc
        property string buffer: ""

        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL,SSID,DEVICE device wifi"]

        stdout: SplitParser {
            onRead: data => {
                signalProc.buffer += data + "\n";
            }
        }
        onExited: {
            root.networkStrength = 0;
            root.activeWifiDevice = "";
            const lines = signalProc.buffer.trim().split('\n');
            for (const line of lines) {
                if (!line.startsWith('*'))
                    continue;
                const parts = line.split(':');
                // 格式: *:SIGNAL:SSID:DEVICE  (SSID 可能含冒号，故从尾部取)
                if (parts.length >= 3) {
                    root.networkStrength = parseInt(parts[1]) || 0;
                    root.activeWifiDevice = parts[parts.length - 1];
                }
                break;
            }
            signalProc.buffer = "";
        }
    }

    // -------------------- WiFi 网络功能 --------------------

    property bool isScanning: false
    property ListModel availableNetworks: ListModel {}
    property int availableNetworksCount: 0

    // 扫描 WiFi 网络
    Process {
        id: scanProcess
        property string buffer: ""

        command: ["sh", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY device wifi list --rescan yes"]

        stdout: SplitParser {
            onRead: data => {
                scanProcess.buffer += data + "\n";
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.isScanning = false;
            if (exitCode !== 0)
                return;

            const lines = scanProcess.buffer.trim().split('\n');
            root.availableNetworks.clear();

            // 去重：同一 SSID 保留信号更强的一条
            const networkMap = new Map();
            lines.forEach(line => {
                if (!line || line.trim() === "")
                    return;

                const parts = line.split(':');
                if (parts.length < 3)
                    return;

                const security = parts[parts.length - 1];
                const signal = parseInt(parts[parts.length - 2]);
                const ssid = parts.slice(0, parts.length - 2).join(':');

                if (!ssid || ssid.trim() === "" || isNaN(signal) || signal < 0 || signal > 100)
                    return;

                const existing = networkMap.get(ssid);
                if (!existing || signal > existing.signal)
                    networkMap.set(ssid, { ssid, signal, security });
            });

            for (const network of networkMap.values())
                root.availableNetworks.append(network);

            root.availableNetworksCount = root.availableNetworks.count;
            scanProcess.buffer = "";
        }
    }

    // 连接 WiFi
    Process {
        id: connectProcess
        command: []
        running: false

        onExited: (exitCode, exitStatus) => {
            root.refresh();
        }
    }

    // 断开 WiFi
    Process {
        id: disconnectProcess
        command: []
        running: false

        onExited: (exitCode, exitStatus) => {
            root.refresh();
        }
    }

    // 扫描网络
    function scanNetworks() {
        if (isScanning)
            return;
        isScanning = true;
        scanProcess.buffer = "";
        scanProcess.running = true;
    }

    function shellQuote(str: string): string {
        return "'" + str.replace(/'/g, `'\\''`) + "'";
    }

    // 连接到网络
    function connectToNetwork(ssid, password) {
        const cmd = password && password !== ""
            ? `nmcli -w 10 device wifi connect ${root.shellQuote(ssid)} password ${root.shellQuote(password)}`
            : `nmcli -w 10 device wifi connect ${root.shellQuote(ssid)}`;
        connectProcess.command = ["sh", "-c", cmd];
        connectProcess.running = true;
    }

    // 断开网络
    function disconnectNetwork() {
        const dev = root.activeWifiDevice || "wlan0";
        disconnectProcess.command = ["sh", "-c", `nmcli -w 5 device disconnect ${dev}`];
        disconnectProcess.running = true;
    }
}
