pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    /* ================== Model ================== */
    ListModel { id: model }
    readonly property alias itemModel: model

    /* ================== Cache ================== */
    readonly property string cacheDir: Quickshell.cacheDir + "/cliphist"
    readonly property string pinsFile: Quickshell.cacheDir + "/clipboard-pins.json"

    /* ================== Pinned ================== */
    property var pinnedIds: []

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", cacheDir])
        loadPinsProc.running = true
        refresh()
    }

    Process {
        id: loadPinsProc

        command: ["bash", "-c", `cat ${JSON.stringify(root.pinsFile)} 2>/dev/null || echo '[]'`]

        stdout: SplitParser {
            onRead: data => {
                try {
                    root.pinnedIds = JSON.parse(data.trim())
                } catch(e) {
                    root.pinnedIds = []
                }
            }
        }
    }

    function savePinnedIds() {
        Quickshell.execDetached({
            command: ["sh", "-c", `mkdir -p ${JSON.stringify(Quickshell.cacheDir)} && printf '%s' ${JSON.stringify(JSON.stringify(root.pinnedIds))} > ${JSON.stringify(root.pinsFile)}`]
        })
    }

    function isPinned(id) {
        return pinnedIds.includes(id)
    }

    function togglePin(id) {
        if (pinnedIds.includes(id)) {
            pinnedIds = pinnedIds.filter(i => i !== id)
        } else {
            pinnedIds = [...pinnedIds, id]
        }
        savePinnedIds()
    }

    /* =================== API ================== */

    function refresh() {
        readProc.buffer = []
        readProc.running = true
    }

    // 剪贴板内容变化时自动刷新历史（防抖）
    Connections {
        target: Quickshell

        function onClipboardTextChanged() {
            autoRefreshTimer.restart()
        }
    }

    Timer {
        id: autoRefreshTimer
        interval: 300
        repeat: false
        onTriggered: root.refresh()
    }

    function copy(item) {
        if (!item || !item.id) return

        Quickshell.execDetached([
            "bash", "-c",
            `cliphist decode ${item.id} | wl-copy`
        ])
    }

    /** 删除某条记录 */
    function deleteItem(item) {
        if (!item || !item.id) return
        if (item.type === "image") {
            const path = imagePathFor(item.id)
            Quickshell.execDetached(["rm", path])
            console.log("Deleted cache image:", path)
        }
        if (isPinned(item.id)) {
            togglePin(item.id)
        }
        deleteProc.command = ["cliphist", "delete", item.id]
        deleteProc.running = true
    }

    function imagePathFor(id) {
        return "file://" + cacheDir + "/" + id + ".png"
    }

    /* ================== Internal ================== */

    Process {
        id: readProc
        property var buffer: []
        command: ["cliphist", "list"]

        stdout: SplitParser {
            onRead: line => readProc.buffer.push(line)
        }

        onExited: (code) => {
            if (code !== 0) return
            model.clear()

            readProc.buffer.forEach(line => {
                const spaceIndex = line.indexOf("\t")
                if (spaceIndex === -1) return

                const id = line.slice(0, spaceIndex)
                const preview = line.slice(spaceIndex + 1)

                let type = "text"
                if (preview.startsWith("file://")) {
                    type = "file"
                } else if (preview.indexOf("[binary]") !== -1 || preview.indexOf("binary data") !== -1) {
                    type = "image"
                }

                const item = {
                    id: id,
                    preview: preview.trim(),
                    type: type,
                    imagePath: type === "image" ? imagePathFor(id) : "",
                    cached: false,
                    pinned: isPinned(id)
                }

                model.append(item)

                if (type === "image") {
                    ensureImageCached(item, model.count - 1)
                }
            })
        }
    }

    function ensureImageCached(item, index) {
        const path = imagePathFor(item.id).replace("file://", "")
        root._cacheQueue.push({ id: item.id, index: index, path: path })
        processCacheQueue()
    }

    // ---- 图片缓存队列（串行，避免大量并发进程） ----
    property var _cacheQueue: []

    function processCacheQueue() {
        if (cacheProc.running || root._cacheQueue.length === 0)
            return;

        const task = root._cacheQueue.shift()
        const targetId = JSON.stringify(task.id)
        const targetPath = JSON.stringify(task.path)
        cacheProc.targetId = task.id
        cacheProc.targetPath = task.path
        cacheProc.targetIndex = task.index
        cacheProc.command = ["bash", "-c", `if [ ! -f ${targetPath} ]; then cliphist decode ${targetId} > ${targetPath} 2>/dev/null; fi`]
        cacheProc.running = true
    }

    Process {
        id: cacheProc
        property string targetId: ""
        property string targetPath: ""
        property int targetIndex: -1

        command: []

        onExited: (code) => {
            if (code === 0 && cacheProc.targetIndex >= 0 && cacheProc.targetIndex < model.count) {
                model.setProperty(cacheProc.targetIndex, "cached", true)
                model.setProperty(cacheProc.targetIndex, "imagePath", "file://" + cacheProc.targetPath)
            }
            cacheProc.targetId = ""
            cacheProc.targetPath = ""
            cacheProc.targetIndex = -1
            processCacheQueue()
        }
    }

    Process {
        id: deleteProc

        command: []

        onExited: refresh()
    }
}