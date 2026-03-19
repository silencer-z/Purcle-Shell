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
        return cacheDir + "/" + id + ".png"
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
        // 先检查文件是否已经存在（避免重复解码浪费资源）
        // 这里只是简单的触发，真正的去重判断比较复杂，现在的逻辑是每次刷新都尝试解码
        // 更好的方式是用 ls 或者 test -f 检查，但为了性能简单起见，覆盖写入也可以
        const path = imagePathFor(item.id)

        const proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["bash", "-c", "if [ ! -f '${path}' ]; then cliphist decode ${item.id} > ${path}; fi"]
                onExited: (code) => {
                    // 只有当文件确实存在或解码成功后才更新 UI
                    if (ClipModel.itemModel.count > index) {
                        let data = ClipModel.itemModel.get(index)
                        if (data && data.id === "${item.id}") {
                            data.cached = true
                            data.imagePath = "${path}"
                        }
                    }
                    destroy()
                }
            }
        `, root, "ImageDecoder")

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
