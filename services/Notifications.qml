pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// 通知服务：NotificationServer 接收 → wrapper 封装 → 弹窗队列 / 历史记录。
//
// 生命周期约定：
//   - wrapper 是通知在 UI 层的唯一代理，popupModel / historyModel 的行结构均为 { wrapper }
//   - 通知被服务端关闭（任意 reason：应用撤回、过期、用户 dismiss）→ 从弹窗与历史中移除并销毁
//   - transient 通知只弹不进历史；resident / critical 常驻不自动关闭
//   - 自动关闭尊重应用提供的 expireTimeout，缺省用 defaultTimeoutMs
//   - keepOnReload：配置重载后从 server.trackedNotifications 恢复历史
Singleton {
    id: root

    // ==== 配置 ====
    readonly property int maxVisiblePopups: 10
    readonly property int defaultTimeoutMs: 5000
    property bool doNotDisturb: false
    property bool popupsDisabled: false

    // ==== 模型 ====
    property ListModel popupModel: ListModel {}
    property ListModel historyModel: ListModel {}

    readonly property int popupCount: popupModel.count
    readonly property int historyCount: historyModel.count

    // 全局时钟（相对时间显示用，半分钟粒度）
    property date currentTime: new Date()

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.currentTime = new Date()
    }

    // 存活 wrapper 注册表（clearAll 用）
    property var wrappers: []

    // ==== Wrapper：UI 层通知代理 ====
    component NotifWrapper: QtObject {
        id: wrapper

        required property Notification notification

        property bool finalized: false
        property bool inPopup: false
        property bool inHistory: false

        readonly property string summary: notification?.summary ?? ""
        readonly property string body: notification?.body ?? ""
        readonly property string appName: notification?.appName || qsTr("System")
        readonly property string appIcon: notification?.appIcon ?? ""
        readonly property string image: notification?.image ?? ""
        readonly property int urgency: notification?.urgency ?? NotificationUrgency.Normal
        readonly property var actions: notification?.actions ?? []
        readonly property date time: new Date()

        readonly property string timeStr: {
            const diff = (root.currentTime - wrapper.time) / 1000;
            if (diff < 60)
                return qsTr("now");
            if (diff < 3600)
                return Math.floor(diff / 60) + qsTr("m");
            if (diff < 86400)
                return Math.floor(diff / 3600) + qsTr("h");
            return Math.floor(diff / 86400) + qsTr("d");
        }

        // 自动关闭时长（0 = 常驻）
        readonly property int expireMs: {
            if (notification?.resident)
                return 0;
            if (urgency === NotificationUrgency.Critical)
                return 0;
            const t = Math.round(notification?.expireTimeout ?? -1);
            return t > 0 ? t : root.defaultTimeoutMs;
        }

        // 弹窗自动关闭定时器（QtObject 无默认属性，需用属性内联实例化）
        property Timer autoTimer: Timer {
            interval: Math.max(1, wrapper.expireMs)
            onTriggered: root.hidePopup(wrapper)
        }

        function startAutoTimer(): void {
            if (wrapper.expireMs > 0)
                wrapper.autoTimer.restart();
            else
                wrapper.autoTimer.stop();
        }

        // 服务端关闭：
        //   Expired / Dismissed：正常结束 → 收起弹窗，历史作为记录保留
        //   CloseRequested：应用主动撤回（如替换通知）→ 从弹窗与历史中移除并销毁
        property Connections closedConn: Connections {
            target: wrapper.notification

            function onClosed(reason): void {
                if (reason === NotificationCloseReason.CloseRequested)
                    root.removeWrapper(wrapper);
                else
                    root.hidePopup(wrapper);
            }
        }

        function invoke(actionId: string): void {
            try {
                notification?.invokeAction(actionId);
            } catch (e) {
            }
        }
    }

    Component {
        id: wrapperComponent

        NotifWrapper {}
    }

    // ==== 接收通知 ====
    NotificationServer {
        id: server

        keepOnReload: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        imageSupported: true

        onNotification: notif => root.track(notif, false)
    }

    Component.onCompleted: {
        // 配置重载后恢复仍在服务端存续的通知（只进历史，不重新弹出）
        for (const n of server.trackedNotifications.values)
            root.track(n, true);
    }

    function track(notif: Notification, recovered: bool): void {
        if (!notif)
            return;
        notif.tracked = true;

        const wrapper = wrapperComponent.createObject(root, {
            notification: notif
        });
        if (!wrapper) {
            console.warn("[Notifications] 创建 wrapper 失败");
            return;
        }
        wrappers.push(wrapper);

        // transient：只弹不进历史；DND / 恢复：不弹
        const wantPopup = !recovered && !doNotDisturb && !popupsDisabled;
        const wantHistory = !notif.transient;

        if (wantPopup)
            showPopup(wrapper);
        else if (wantHistory)
            addToHistory(wrapper);
    }

    // ==== 弹窗队列 ====
    function showPopup(wrapper: var): void {
        if (wrapper.finalized || wrapper.inPopup)
            return;

        addToHistory(wrapper);
        wrapper.inPopup = true;
        popupModel.append({
            wrapper: wrapper
        });
        wrapper.startAutoTimer();

        // 超出可见上限时收起最早的
        if (popupModel.count > maxVisiblePopups)
            hidePopup(popupModel.get(0).wrapper);
    }

    function hidePopup(wrapper: var): void {
        if (!wrapper || !wrapper.inPopup)
            return;

        wrapper.inPopup = false;
        for (let i = 0; i < popupModel.count; i++) {
            if (popupModel.get(i).wrapper === wrapper) {
                popupModel.remove(i);
                break;
            }
        }
    }

    // ==== 历史 ====
    function addToHistory(wrapper: var): void {
        if (wrapper.finalized || wrapper.inHistory)
            return;

        wrapper.inHistory = true;
        historyModel.insert(0, {
            wrapper: wrapper
        });
    }

    // ==== 移除 / 销毁 ====
    function removeWrapper(wrapper: var): void {
        if (!wrapper || wrapper.finalized)
            return;

        wrapper.finalized = true;
        hidePopup(wrapper);

        if (wrapper.inHistory) {
            wrapper.inHistory = false;
            for (let i = 0; i < historyModel.count; i++) {
                if (historyModel.get(i).wrapper === wrapper) {
                    historyModel.remove(i);
                    break;
                }
            }
        }

        const idx = wrappers.indexOf(wrapper);
        if (idx !== -1)
            wrappers.splice(idx, 1);

        Qt.callLater(() => {
            try {
                wrapper.destroy();
            } catch (e) {
            }
        });
    }

    // ==== 用户操作 ====

    // 关闭弹窗（保留历史，同时告知服务端）
    function dismiss(wrapper: var): void {
        if (!wrapper)
            return;
        hidePopup(wrapper);
        try {
            wrapper.notification?.dismiss();
        } catch (e) {
        }
    }

    // 从历史彻底移除
    function remove(wrapper: var): void {
        if (!wrapper)
            return;
        hidePopup(wrapper);
        try {
            wrapper.notification?.dismiss();
        } catch (e) {
        }
        removeWrapper(wrapper);
    }

    function clearAll(): void {
        // 拷贝后逐个移除（removeWrapper 会修改 wrappers 数组）
        const list = wrappers.slice();
        for (const w of list) {
            try {
                w.notification?.dismiss();
            } catch (e) {
            }
            removeWrapper(w);
        }
    }
}
