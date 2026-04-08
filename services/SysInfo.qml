pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

/* 创建服务用于获取系统信息 */
Singleton{
    id:root


    /* 用户信息 */
    property string userName: ""
    property string hostName: ""
    property string osName: ""
    property string kernelVersion: ""
    property string uptime: ""
    property string packages: ""
    property string ipv4: ""

    /* 内存信息 */
    property double memoryTotal: 0
    property double memoryUsed: 0
    property double memoryAvailable: (memoryTotal - memoryUsed) || 0
    property double memoryUsedPercentage: memoryTotal > 0 ? (memoryUsed / memoryTotal * 100) : 0

    /* 交换空间信息 */
    property double swapTotal: 0
    property double swapUsed: 0
    property double swapFree: (swapTotal - swapUsed) || 0
    property double swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal * 100) : 0

    /* 磁盘信息 */
    property double diskTotal: 0
    property double diskUsed: 0
    property double diskFree: (diskTotal - diskUsed) || 0
    property double diskUsedPercentage: diskTotal > 0 ? (diskUsed / diskTotal * 100) : 0

    Process {
        id: systemInfoProcess
        command: [
            "sh", "-c",
            "fastfetch --config ~/.config/fastfetch/mini.jsonc --format json"
        ]
        running: false

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                // fastfetch 输出是多行 JSON，把它们拼接在一起
                systemInfoProcess.buffer += data
            }
        }

        onExited: (exitCode, exitStatus) => {
            running = false

            try {
                let jsonText = systemInfoProcess.buffer.trim()

                // 有时候 fastfetch 会在前后加额外输出，尝试提取纯 JSON 段
                const start = jsonText.indexOf('[')
                const end = jsonText.lastIndexOf(']')
                if (start >= 0 && end > start)
                    jsonText = jsonText.slice(start, end + 1)

                let arr = JSON.parse(jsonText)
                let info = {}

                for (let i = 0; i < arr.length; i++) {
                    const item = arr[i]
                    switch (item.type) {
                        case "OS":
                            info.osName = item.result.prettyName
                            break
                        case "Kernel":
                            info.kernelVersion = item.result.release
                            break
                        case "Title":
                            info.userName = item.result.userName
                            info.hostName = item.result.hostName
                            break
                        case "Uptime":
                            let uptimeSec = Math.floor(item.result.uptime/1000)
                            let days = Math.floor(uptimeSec / 86400)
                            let hours = Math.floor((uptimeSec % 86400) / 3600)
                            let mins = Math.floor((uptimeSec % 3600) / 60)
                            info.uptime = `${days}d ${hours}h ${mins}m`
                            break
                        case "Packages":
                            info.packages = item.result.all
                            break
                        case "Memory":
                            info.memoryTotal = item.result.total || 0
                            info.memoryUsed = item.result.used || 0
                            break
                        case "Swap":
                            if (item.result && item.result.length > 0) {
                                info.swapTotal = item.result[0].total || 0
                                info.swapUsed = item.result[0].used || 0
                            }
                            break
                        case "Disk":
                            let root = item.result.find(d => d.mountpoint === "/")
                            if (root && root.bytes) {
                                let total = root.bytes.total
                                let used = root.bytes.used
                                info.diskTotal = total
                                info.diskUsed = used
                            }
                            break
                        case "LocalIp":
                            if (item.result && item.result.length > 0) {
                                let ipv4WithCidr = item.result[0].ipv4
                                if (ipv4WithCidr) {
                                    info.ipv4 = ipv4WithCidr.split('/')[0]
                                }
                            }
                            break
                    }
                }

                SysInfo.userName = info.userName ?? ""
                SysInfo.hostName = info.hostName ?? ""
                SysInfo.osName = info.osName ?? ""
                SysInfo.kernelVersion = info.kernelVersion ?? ""
                SysInfo.uptime = info.uptime ?? ""
                SysInfo.packages = info.packages?.toString() ?? "0"

                SysInfo.memoryTotal = info.memoryTotal ?? 0
                SysInfo.memoryUsed = info.memoryUsed ?? 0

                SysInfo.swapTotal = info.swapTotal ?? 0
                SysInfo.swapUsed = info.swapUsed ?? 0

                SysInfo.diskTotal = info.diskTotal || 0
                SysInfo.diskUsed = info.diskUsed || 0
                SysInfo.ipv4 = info.ipv4 ?? ""

            } catch (e) {
                console.log("❌ Failed to parse fastfetch JSON:", e)
                console.log("Raw data:", systemInfoProcess.buffer)
            }
            systemInfoProcess.buffer = ""
        }
    }

    function loadUserInfo() {
        if (!systemInfoProcess.running) {
            systemInfoProcess.buffer = ""
            systemInfoProcess.running = true
        }
    }

}
