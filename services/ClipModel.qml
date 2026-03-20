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

    Component.onCompleted: {
        // 启动时确保存储目录存在
        Quickshell.execDetached(["mkdir", "-p", cacheDir])
        refresh()
    }

    /* =================== API =================== */

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

                // 类型判断
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
                    cached: false
                }

                model.append(item)

                // 图片异步缓存
                if (type === "image") {
                    ensureImageCached(item, model.count - 1)
                }
            })
        }
    }

    // 异步解码图片
    function ensureImageCached(item, index) {
        const path = imagePathFor(item.id).replace("file://", "")
        const targetIndex = index
        const targetPath = path
        
        // 创建动态对象时，将 model 直接作为属性传入
        const proc = Qt.createQmlObject(`
            import QtQuick
            import Quickshell.Io
            Process {
                property var targetModel: null
                command: ["bash", "-c", "if [ ! -f '${targetPath}' ]; then cliphist decode ${item.id} > '${targetPath}' 2>/dev/null; fi"]
                onExited: (code) => {
                    // 通过传入的 model 属性来访问，避免单例访问问题
                    if (targetModel && targetModel.count > ${targetIndex}) {
                        targetModel.setProperty(${targetIndex}, "cached", true)
                        targetModel.setProperty(${targetIndex}, "imagePath", "file://${targetPath}")
                    }
                    destroy()
                }
            }
        `, root, "ImageDecoder")

        // 将 model 直接传递给动态对象
        proc.targetModel = model
        proc.running = true
    }

    // 删除记录进程
    Process {
        id: deleteProc
        // 使用 targetId 避免与 Process 自身的 id 属性冲突
        property string targetId: ""

        command: ["cliphist", "delete", targetId]

        // 删除完成后刷新列表
        onExited: refresh()
    }
}
