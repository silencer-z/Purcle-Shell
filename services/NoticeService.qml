pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // --- 配置 ---
    property int maxVisibleNotifications: 10
    property int popupTimeoutMs: 5000
    property bool doNotDisturb: false
    property bool popupsDisabled: false

    // --- 模型 ---
    property ListModel historyModel: ListModel {}   // { seq }
    property ListModel popupModel: ListModel {}     // { seq }

    property var notificationQueue: []
    property var _wrappers: ({})

    // 全局时间（用于 timeStr）
    property date currentTime: new Date()
    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.currentTime = new Date()
    }

    // 内部状态
    property bool _addGateBusy: false
    property int _seqCounter: 0

    // -------------------- Wrapper --------------------
    component NotifWrapper: QtObject {
        id: wrapper

        required property Notification notification
        property bool popup: false
        property int seq: 0
        property bool _destroyed: false
        property bool _removing: false

        // 导出数据
        readonly property string summary: notification ? notification.summary : ""
        readonly property string body: notification ? notification.body : ""
        readonly property string appName: notification ? (notification.appName || "System") : "System"
        readonly property string appIcon: notification ? notification.appIcon : ""
        readonly property string image: notification ? notification.image : ""
        readonly property int urgency: notification ? notification.urgency : 0
        readonly property var actions: notification ? notification.actions : []
        readonly property date time: new Date()

        readonly property string timeStr: {
            const diff = (root.currentTime - time) / 1000
            if (diff < 60) return "now"
            if (diff < 3600) return Math.floor(diff / 60) + "m"
            if (diff < 86400) return Math.floor(diff / 3600) + "h"
            return "1d+"
        }

        // 自动关闭
        property Timer autoTimer:Timer {
            interval: root.popupTimeoutMs
            repeat: false
            onTriggered: {
                if (!wrapper._destroyed)
                    wrapper.popup = false
            }
        }

        onPopupChanged: {
            if (popup) autoTimer.restart()
            else {
                autoTimer.stop()
                if (!wrapper._removing) {
                    wrapper._removing = true
                    root.removeFromPopup(wrapper)
                }
            }
        }

        property Connections conn: Connections {
            target: wrapper.notification
            onDropped: root.removeWrapper(wrapper)
        }

        function invoke(actionId) {
            if (notification) {
                try { notification.invokeAction(actionId) } catch(e) {}
            }
        }
    }

    Component { id: notifComponent; NotifWrapper {} }

    // -------------------- NotificationServer --------------------
    NotificationServer {
        id: server
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        imageSupported: true

        onNotification: function(notif) {
            if (!notif) return
            notif.tracked = true

            const seq = ++root._seqCounter
            const showPopup = !root.doNotDisturb && !root.popupsDisabled

            const wrapper = notifComponent.createObject(root, {
                notification: notif,
                seq: seq,
                popup: showPopup
            })

            if (!wrapper) {
                console.error("Failed to create wrapper.")
                return
            }

            root._wrappers[seq] = wrapper

            // 插入历史模型
            historyModel.insert(0, { seq: seq })

            // 加入弹窗队列
            if (showPopup) {
                notificationQueue.push(seq)
                root.processQueue()
            }
        }
    }

    // -------------------- 弹窗队列 --------------------
    Timer {
        id: queueProcessor
        interval: 200
        repeat: false
        onTriggered: {
            root._addGateBusy = false
            root.processQueue()
        }
    }

    function processQueue() {
        if (_addGateBusy || popupsDisabled || doNotDisturb)
            return
        if (notificationQueue.length === 0)
            return
        if (popupModel.count >= maxVisibleNotifications)
            return

        const seq = notificationQueue.shift()
        const wrapper = root._wrappers[seq]
        if (!wrapper) return

        popupModel.append({ seq: seq, wrapper: wrapper })
        wrapper.popup = true

        _addGateBusy = true
        queueProcessor.restart()
    }

    function removeFromPopup(wrapper) {
        const seq = wrapper.seq
        for (let i = 0; i < popupModel.count; i++) {
            if (popupModel.get(i).seq === seq) {
                popupModel.remove(i)
                break
            }
        }
        Qt.callLater(processQueue)
    }

    // -------------------- 删除通知 --------------------
    function removeWrapper(wrapper) {
        if (!wrapper || wrapper._destroyed)
            return

        wrapper._destroyed = true

        // 1. 从 popupModel 移除
        removeFromPopup(wrapper)

        // 2. 从 notificationQueue 移除
        const qIdx = notificationQueue.indexOf(wrapper.seq)
        if (qIdx !== -1)
            notificationQueue.splice(qIdx, 1)

        // 3. 从 historyModel 移除
        for (let i = 0; i < historyModel.count; i++) {
            if (historyModel.get(i).seq === wrapper.seq) {
                historyModel.remove(i)
                break
            }
        }

        // 4. 从映射中删除
        delete _wrappers[wrapper.seq]

        // 5. 销毁 wrapper（延后执行）
        Qt.callLater(() => {
            try { wrapper.destroy() } catch(e) {}
        })
    }

    // -------------------- 获取通知 --------------------
    function getWrapper(seq) {
        return _wrappers[seq] || null
    }

    // -------------------- 用户操作 --------------------
    function dismissSeq(seq) {
        const w = _wrappers[seq]
        if (!w) return
        w.popup = false
        try { w.notification.dismiss() } catch(e) { removeWrapper(w) }
    }

    function dismiss(wrapperOrSeq) {
        if (typeof wrapperOrSeq === "number")
            dismissSeq(wrapperOrSeq)
        else if (wrapperOrSeq)
            dismissSeq(wrapperOrSeq.seq)
    }

    function removeSeq(seq) {
        const w = _wrappers[seq]
        if (w) removeWrapper(w)
    }

    function clearAll() {
        popupModel.clear()
        historyModel.clear()
        notificationQueue = []

        const keys = Object.keys(_wrappers)
        for (const k of keys) {
            const w = _wrappers[k]
            if (!w) continue
            try { w.notification.dismiss() } catch(e){}
            try { w.destroy() } catch(e){}
        }
        _wrappers = ({})
    }

    onDoNotDisturbChanged: if (doNotDisturb) {
        const seqs = []
        for (let i = 0; i < popupModel.count; i++)
            seqs.push(popupModel.get(i).seq)

        seqs.forEach(seq => {
            const w = root._wrappers[seq]
            if (w) w.popup = false
        })

        notificationQueue = []
    }
}
