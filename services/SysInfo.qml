pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string userName: ""
    property string hostName: ""
    property string osName: ""
    property string kernelVersion: ""
    property string uptime: ""
    property string packages: ""
    property string ipv4: ""

    property double memoryTotal: 0
    property double memoryUsed: 0
    property double memoryAvailable: (memoryTotal - memoryUsed) || 0
    property double memoryUsedPercentage: memoryTotal > 0 ? (memoryUsed / memoryTotal * 100) : 0

    property double swapTotal: 0
    property double swapUsed: 0
    property double swapFree: (swapTotal - swapUsed) || 0
    property double swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal * 100) : 0

    property double diskTotal: 0
    property double diskUsed: 0
    property double diskFree: (diskTotal - diskUsed) || 0
    property double diskUsedPercentage: diskTotal > 0 ? (diskUsed / diskTotal * 100) : 0

    function formatUptime(seconds: int): string {
        const days = Math.floor(seconds / 86400);
        const hours = Math.floor((seconds % 86400) / 3600);
        const mins = Math.floor((seconds % 3600) / 60);
        return `${days}d ${hours}h ${mins}m`;
    }

    // 静态信息：启动时跑一次 fastfetch
    Process {
        id: staticProc

        command: ["fastfetch", "--config", Quickshell.shellPath("assets/fastfetch/mini.jsonc"), "--format", "json"]
        running: false
        property string buffer: ""

        stdout: SplitParser {
            onRead: data => staticProc.buffer += data
        }

        onExited: {
            try {
                let jsonText = staticProc.buffer.trim();
                const start = jsonText.indexOf('[');
                const end = jsonText.lastIndexOf(']');
                if (start >= 0 && end > start)
                    jsonText = jsonText.slice(start, end + 1);

                const arr = JSON.parse(jsonText);
                for (let i = 0; i < arr.length; i++) {
                    const item = arr[i];
                    switch (item.type) {
                    case "OS":
                        root.osName = item.result.prettyName ?? "";
                        break;
                    case "Kernel":
                        root.kernelVersion = item.result.release ?? "";
                        break;
                    case "Title":
                        root.userName = item.result.userName ?? "";
                        root.hostName = item.result.hostName ?? "";
                        break;
                    case "Packages":
                        root.packages = item.result.all?.toString() ?? "0";
                        break;
                    case "LocalIp":
                        if (item.result && item.result.length > 0 && item.result[0].ipv4)
                            root.ipv4 = item.result[0].ipv4.split('/')[0];
                        break;
                    }
                }
            } catch (e) {
                console.warn("[SysInfo] 解析 fastfetch 失败", e);
            }
            staticProc.buffer = "";
        }
    }

    // 动态信息：/proc + df，避免每分钟拉一次 fastfetch
    Process {
        id: dynamicProc

        command: ["sh", "-c", `
awk '
  /^MemTotal:/ { mt=$2*1024 }
  /^MemAvailable:/ { ma=$2*1024 }
  /^SwapTotal:/ { st=$2*1024 }
  /^SwapFree:/ { sf=$2*1024 }
  END { printf "mem %s %s\\nswap %s %s\\n", mt+0, (mt-ma)+0, st+0, (st-sf)+0 }
' /proc/meminfo
awk '{ printf "uptime %d\\n", $1 }' /proc/uptime
df -B1 / | awk 'NR==2 { printf "disk %s %s\\n", $2, $3 }'
`]
        running: false
        property string buffer: ""

        stdout: SplitParser {
            onRead: data => dynamicProc.buffer += data + "\n"
        }

        onExited: {
            const lines = dynamicProc.buffer.trim().split("\n");
            for (const line of lines) {
                const p = line.trim().split(" ");
                if (p[0] === "mem" && p.length >= 3) {
                    root.memoryTotal = Number(p[1]) || 0;
                    root.memoryUsed = Number(p[2]) || 0;
                } else if (p[0] === "swap" && p.length >= 3) {
                    root.swapTotal = Number(p[1]) || 0;
                    root.swapUsed = Number(p[2]) || 0;
                } else if (p[0] === "uptime" && p.length >= 2) {
                    root.uptime = root.formatUptime(parseInt(p[1], 10) || 0);
                } else if (p[0] === "disk" && p.length >= 3) {
                    root.diskTotal = Number(p[1]) || 0;
                    root.diskUsed = Number(p[2]) || 0;
                }
            }
            dynamicProc.buffer = "";
        }
    }

    Component.onCompleted: {
        staticProc.running = true;
        dynamicProc.running = true;
    }

    Timer {
        interval: 15000
        repeat: true
        onTriggered: {
            if (!dynamicProc.running)
                dynamicProc.running = true;
        }
    }
}
