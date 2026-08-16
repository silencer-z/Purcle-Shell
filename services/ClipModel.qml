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
        loadPinnedIds()
        refresh()
    }

    function loadPinnedIds() {
        const proc = Qt.createQmlObject(`
            import QtQuick
            import Quickshell.Io
            Process {
                command: ["bash", "-c", "cat '${pinsFile}' 2>/dev/null || echo '[]'"]
                onExited: (code) => {
                    try {
                        const data = JSON.parse(readAll())
                        pinnedIds = data
                    } catch(e) {
                        pinnedIds = []
                    }
                    destroy()
                }
            }
        `, root, "LoadPins")
        proc.running = true
    }

    function savePinnedIds() {
        const data = JSON.stringify(pinnedIds)
        Quickshell.execDetached([
            "bash", "-c",
            `mkdir -p '${Quickshell.cacheDir}' && echo '${data}' > '${pinsFile}'`
        ])
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
        deleteProc.targetId = item.id
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
        const targetIndex = index
        const targetPath = path

        const proc = Qt.createQmlObject(`
            import QtQuick
            import Quickshell.Io
            Process {
                property var targetModel: null
                command: ["bash", "-c", "if [ ! -f '${targetPath}' ]; then cliphist decode ${item.id} > '${targetPath}' 2>/dev/null; fi"]
                onExited: (code) => {
                    if (targetModel && targetModel.count > ${targetIndex}) {
                        targetModel.setProperty(${targetIndex}, "cached", true)
                        targetModel.setProperty(${targetIndex}, "imagePath", "file://${targetPath}")
                    }
                    destroy()
                }
            }
        `, root, "ImageDecoder")

        proc.targetModel = model
        proc.running = true
    }

    Process {
        id: deleteProc
        property string targetId: ""

        command: ["cliphist", "delete", targetId]

        onExited: refresh()
    }
}