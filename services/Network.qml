pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick


Singleton {
    id: root

    property bool wifi: true
    property bool ethernet: false
    property int updateInterval: 1000
    property string networkName: ""
    property int networkStrength
    property string materialSymbol: ethernet ? "lan" :
        (Network.networkName.length > 0 && Network.networkName != "lo") ? (
        Network.networkStrength > 80 ? "signal_wifi_4_bar" :
        Network.networkStrength > 60 ? "network_wifi_3_bar" :
        Network.networkStrength > 40 ? "network_wifi_2_bar" :
        Network.networkStrength > 20 ? "network_wifi_1_bar" :
        "signal_wifi_0_bar"
    ) : "signal_wifi_off"
    function update() {
        updateConnectionType.startCheck();
        updateNetworkName.running = true;
        updateNetworkStrength.running = true;
    }

    Timer {
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            root.update();
            interval = root.updateInterval;
        }
    }

    // 是否连接网络或者WIFI
    Process {
        id: updateConnectionType
        property string buffer
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE,DEVICE c show --active"]
        running: true
        function startCheck() {
            buffer = "";
            updateConnectionType.running = true;
        }
        stdout: SplitParser {
            onRead: data => {
                updateConnectionType.buffer += data + "\n";
            }
        }
        onExited: (exitCode, exitStatus) => {
            const lines = updateConnectionType.buffer.trim().split('\n');
            let hasEthernet = false;
            let hasWifi = false;
            lines.forEach(line => {
                if (line.includes("ethernet"))
                    hasEthernet = true;
                else if (line.includes("wireless"))
                    hasWifi = true;
            });
            root.ethernet = hasEthernet;
            root.wifi = hasWifi;
        }
    }

    // 网络名称
    Process {
        id: updateNetworkName
        command: ["sh", "-c", "nmcli -t -f NAME c show --active | head -1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.networkName = data;
            }
        }
    }

    // 信号强度
    Process {
        id: updateNetworkStrength
        running: true
        command: ["sh", "-c", "nmcli -f IN-USE,SIGNAL,SSID device wifi | awk '/^\\*/{if (NR!=1) {print $2}}'"]
        stdout: SplitParser {
            onRead: data => {
                root.networkStrength = parseInt(data);
            }
        }
    }

    // -------------------- WiFi 网络功能 --------------------

    property bool isScanning: false
    property ListModel availableNetworks: ListModel {}
    property int availableNetworksCount: 0

    // 扫描 WiFi 网络
    Process {
        id: scanProcess
        property string buffer
        command: ["sh", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY device wifi list --rescan yes"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                scanProcess.buffer += data + "\n";
            }
        }

        onExited: (exitCode, exitStatus) => {
            root.isScanning = false;
            if (exitCode !== 0) {
                console.log("Scan failed with exit code:", exitCode);
                return;
            }

            console.log("Scan completed, parsing results...");

            // 解析扫描结果
            const lines = scanProcess.buffer.trim().split('\n');
            root.availableNetworks.clear();

            console.log("Total lines to parse:", lines.length);

            // 用于去重和跟踪信号强度的 Map
            const networkMap = new Map();

            lines.forEach((line, index) => {
                if (!line || line.trim() === "") {
                    console.log("Skipping empty line at index:", index);
                    return;
                }

                const parts = line.split(':');

                if (parts.length >= 2) {
                    const ssid = parts[0];
                    const signalStr = parts[1];
                    const security = parts.length >= 3 ? parts.slice(2).join(':') : "--";

                    // 跳过空 SSID
                    if (!ssid || ssid.trim() === "") {
                        console.log(`Skipping line ${index}: empty SSID`);
                        return;
                    }

                    // 解析信号强度
                    const signal = parseInt(signalStr);
                    if (isNaN(signal) || signal < 0 || signal > 100) {
                        console.log(`Skipping line ${index}: invalid signal "${signalStr}" for SSID "${ssid}"`);
                        return;
                    }

                    // 如果 SSID 已存在，保留信号更强的
                    if (networkMap.has(ssid)) {
                        const existing = networkMap.get(ssid);
                        if (signal > existing.signal) {
                            console.log(`Updating network "${ssid}": new signal ${signal}% > existing ${existing.signal}%`);
                            networkMap.set(ssid, { ssid: ssid, signal: signal, security: security });
                        } else {
                            console.log(`Skipping duplicate network "${ssid}": current signal ${signal}% <= existing ${existing.signal}%`);
                        }
                    } else {
                        console.log(`Adding new network: "${ssid}" with signal ${signal}%`);
                        networkMap.set(ssid, { ssid: ssid, signal: signal, security: security });
                    }
                } else {
                    console.log(`Skipping malformed line ${index}: not enough parts (${parts.length})`);
                }
            });

            // 将所有有效网络添加到模型
            console.log("Starting to append networks to model...");
            let appendCount = 0;
            for (const network of networkMap.values()) {
                try {
                    console.log(`  Appending network #${appendCount + 1}: SSID="${network.ssid}", Signal=${network.signal}%, Security="${network.security}"`);
                    root.availableNetworks.append({
                        ssid: network.ssid,
                        signal: network.signal,
                        security: network.security
                    });
                    appendCount++;

                    // 验证数据是否正确添加
                    const index = root.availableNetworks.count - 1;
                    const retrieved = root.availableNetworks.get(index);
                    console.log(`    Retrieved from model: SSID="${retrieved.ssid}", Signal=${retrieved.signal}`);
                } catch (e) {
                    console.error("Failed to append network to model:", e);
                }
            }

            console.log("Successfully added", root.availableNetworks.count, "valid networks to model (attempted:", appendCount, ")");
            root.availableNetworksCount = root.availableNetworks.count;
        }
    }

    // 连接 WiFi
    Process {
        id: connectProcess
        command: []
        running: false

        onExited: (exitCode, exitStatus) => {
            root.update();
        }
    }

    // 断开 WiFi
    Process {
        id: disconnectProcess
        command: ["sh", "-c", "nmcli -w 5 device disconnect wlan0"]
        running: false

        onExited: (exitCode, exitStatus) => {
            // 断开后更新状态
            root.update();
        }
    }

    // 扫描网络
    function scanNetworks() {
        if (!isScanning) {
            console.log("Starting network scan...");
            isScanning = true;
            scanProcess.buffer = "";
            scanProcess.running = true;
        } else {
            console.log("Scan already in progress, skipping...");
        }
    }

    // 连接到网络
    function connectToNetwork(ssid, password) {
        const cmd = password && password !== ""
            ? `nmcli -w 10 device wifi connect "${ssid}" password "${password}"`
            : `nmcli -w 10 device wifi connect "${ssid}"`;
        connectProcess.command = ["sh", "-c", cmd];
        connectProcess.running = true;
    }

    // 断开网络
    function disconnectNetwork() {
        disconnectProcess.running = true;
    }
}
