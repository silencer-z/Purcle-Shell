import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.Configs
import qs.services

// 左侧壁纸面板内容（表面由 drawers/LeftPanelPath 绘制）
Item {
    id: root

    required property int maxHeight

    function close() {
        Visibilities.wallpaper = false;
    }

    function focusInput() {
        searchInput.forceActiveFocus();
    }

    property string searchQuery: ""
    property string debouncedQuery: ""

    readonly property var filteredWallpapers: Wallpapers.matching(root.debouncedQuery)

    Timer {
        id: searchDebounce

        interval: 300
        repeat: false
        onTriggered: root.debouncedQuery = root.searchQuery
    }

    onSearchQueryChanged: searchDebounce.restart()

    readonly property int filletSize: Config.appearance.border.rounding
    readonly property int contentPadding: Config.appearance.padding.normal
    readonly property int bodyWidth: 420

    implicitWidth: root.filletSize + root.bodyWidth + root.contentPadding * 2
    implicitHeight: root.maxHeight

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: root.contentPadding
        anchors.rightMargin: root.filletSize + root.contentPadding
        anchors.topMargin: root.contentPadding
        anchors.bottomMargin: root.contentPadding
        spacing: Config.appearance.spacing.small

        // ==== 标题栏 ====
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            StyledText {
                text: "壁纸选择"
                font.pixelSize: Config.appearance.fonts.size.large
                font.bold: true
                color: Theme.text
            }

            StyledText {
                text: Wallpapers.currentWallpaperName || "未设置"
                font.pixelSize: Config.appearance.fonts.size.medium
                color: Theme.overlay0
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
            }

            // 随机按钮
            Rectangle {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 30
                radius: 10
                color: randomBtn.containsMouse ? Theme.surface1 : Theme.surface0
                border.width: 1
                border.color: Theme.surface2

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    MaterialSymbol {
                        text: "shuffle"
                        size: 16
                        color: Theme.mauve
                    }
                    StyledText {
                        text: "随机"
                        font.pixelSize: Config.appearance.fonts.size.small
                        color: Theme.text
                    }
                }

                MouseArea {
                    id: randomBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Wallpapers.setRandom(root.filteredWallpapers)
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }

        // ==== 搜索框 ====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            radius: 12
            color: searchInput.activeFocus ? Theme.surface1 : Theme.surface0
            border.width: 1
            border.color: searchInput.activeFocus ? Theme.mauve : Theme.surface2

            Behavior on color {
                ColorAnim {}
            }

            Behavior on border.color {
                ColorAnim {}
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                MaterialSymbol {
                    text: "search"
                    size: 18
                    color: Theme.overlay0
                }

                StyledTextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    font.pixelSize: Config.appearance.fonts.size.medium
                    color: Theme.text
                    onTextChanged: root.searchQuery = text
                    Keys.onEscapePressed: {
                        if (searchInput.text) {
                            searchInput.text = "";
                        } else {
                            root.close();
                        }
                    }
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Up) {
                            wallpaperPath.decrementCurrentIndex();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            wallpaperPath.incrementCurrentIndex();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            const list = root.filteredWallpapers;
                            if (wallpaperPath.currentIndex >= 0 && wallpaperPath.currentIndex < list.length)
                                Wallpapers.setWallpaper(list[wallpaperPath.currentIndex]);
                            event.accepted = true;
                        }
                    }
                }

                MaterialSymbol {
                    text: root.searchQuery ? "close" : ""
                    size: 16
                    color: Theme.overlay0
                    visible: root.searchQuery !== ""
                    MouseArea {
                        anchors.fill: parent
                        onClicked: searchInput.text = ""
                    }
                }
            }
        }

        // ==== 配色方案 ====
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MaterialSymbol {
                text: "palette"
                size: 18
                color: Theme.overlay0
            }

            StyledText {
                text: "配色"
                font.pixelSize: Config.appearance.fonts.size.medium
                color: Theme.overlay0
            }

            // 方案切换：预设 / 动态(matugen) / Pywal
            RowLayout {
                spacing: 4

                SchemeButton {
                    label: "预设"
                    icon: "style"
                    checked: Theme.scheme === "preset"
                    onClicked: Theme.usePreset(Theme.presetName)
                }

                SchemeButton {
                    label: "动态"
                    icon: "auto_awesome"
                    checked: Theme.scheme === "matugen"
                    onClicked: Theme.useMatugen()
                }

                SchemeButton {
                    label: "Pywal"
                    icon: "terminal"
                    checked: Theme.scheme === "pywal"
                    onClicked: Theme.usePywal()
                }
            }

            // matugen 明暗切换
            Rectangle {
                visible: Theme.scheme === "matugen"
                Layout.preferredHeight: 28
                Layout.preferredWidth: darkBtnLayout.implicitWidth + 20
                radius: 10
                color: darkBtn.containsMouse ? Theme.surface1 : Theme.surface0
                border.width: 1
                border.color: Config.colors.isDarkMode ? Theme.surface2 : Theme.mauve

                RowLayout {
                    id: darkBtnLayout

                    anchors.centerIn: parent
                    spacing: 6

                    MaterialSymbol {
                        text: Config.colors.isDarkMode ? "dark_mode" : "light_mode"
                        size: 14
                        color: Theme.text
                    }
                    StyledText {
                        text: Config.colors.isDarkMode ? "暗色" : "亮色"
                        font.pixelSize: Config.appearance.fonts.size.small
                        color: Theme.text
                    }
                }

                MouseArea {
                    id: darkBtn

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Config.colors.isDarkMode = !Config.colors.isDarkMode
                }

                Behavior on color {
                    ColorAnim {}
                }
            }

            Item {
                Layout.fillWidth: true
            }

            // 预设列表
            RowLayout {
                visible: Theme.scheme === "preset"
                spacing: 8

                Repeater {
                    model: Theme.presets

                    delegate: PresetChip {
                        required property QtObject modelData

                        preset: modelData
                    }
                }
            }
        }

        // ==== 壁纸轮播 ====
        PathView {
            id: wallpaperPath

            Layout.fillWidth: true
            Layout.fillHeight: true

            // 卡片宽度由面板宽度决定
            readonly property real focusedWidth: width * 0.90
            readonly property real normalWidth: width * 0.72
            readonly property real cardHeight: normalWidth * 9 / 16
            // 可见卡片数由面板高度推算（奇数，至少 3，居中项为聚焦卡片）
            readonly property int visibleCount: Math.max(3, 2 * Math.round(height / (cardHeight * 1.4)) + 1)

            model: ScriptModel {
                values: root.filteredWallpapers
            }
            pathItemCount: wallpaperPath.visibleCount
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            clip: true
            focus: true
            cacheItemCount: 5

            // 当前壁纸居中（列表异步加载完成后 onModelChanged 会再触发一次，无需重试循环）
            onModelChanged: {
                const vals = model?.values ?? [];
                const idx = vals.indexOf(Wallpapers.currentWallpaper);
                wallpaperPath.currentIndex = idx !== -1 ? idx : (model?.count > 0 ? 0 : 0);
            }

            path: Path {
                startX: wallpaperPath.width / 2
                startY: 0

                PathLine {
                    x: wallpaperPath.width / 2
                    y: wallpaperPath.height
                }
            }

            delegate: Item {
                id: delegateItem

                required property var modelData
                required property int index

                readonly property bool isCurrent: PathView.isCurrentItem
                readonly property bool isApplied: modelData === Wallpapers.currentWallpaper
                // 卡片宽度由面板宽度决定，聚焦项略大；高度 16:9
                readonly property real cardWidth: isCurrent ? wallpaperPath.focusedWidth : wallpaperPath.normalWidth
                readonly property real cardHeight: cardWidth * 9 / 16

                implicitWidth: wallpaperPath.width
                implicitHeight: cardHeight * 1.15

                z: isCurrent ? 100 : 1
                opacity: isCurrent ? 1.0 : 0.75

                Behavior on implicitHeight {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                Rectangle {
                    id: cardRect
                    anchors.centerIn: parent
                    color: Theme.surface0
                    implicitWidth: delegateItem.cardWidth
                    implicitHeight: delegateItem.cardHeight
                    clip: true
                    layer.enabled: true
                    radius: 16
                    border.width: delegateItem.isApplied ? 3 : 0
                    border.color: Theme.mauve
                    Image {
                        id: wallpaperImg
                        anchors.fill: parent
                        source: "file://" + delegateItem.modelData
                        sourceSize: Qt.size(300, 300)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    // 应用标记
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 8
                        width: appliedText.width + 12
                        height: 20
                        radius: 10
                        color: Theme.mauve
                        visible: delegateItem.isApplied

                        StyledText {
                            id: appliedText
                            anchors.centerIn: parent
                            text: "使用中"
                            font.pixelSize: Config.appearance.fonts.size.tiny
                            color: Theme.onPrimary
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!delegateItem.isCurrent) {
                                wallpaperPath.currentIndex = delegateItem.index;
                            } else {
                                Wallpapers.setWallpaper(delegateItem.modelData);
                            }
                        }
                    }

                    Behavior on implicitWidth {
                        NumberAnimation { duration: Config.appearance.animations.durations.normal; easing.type: Easing.OutCubic }
                    }
                    Behavior on implicitHeight {
                        NumberAnimation { duration: Config.appearance.animations.durations.normal; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }

    Keys.onPressed: (event) => {
        if (searchInput.inputMethodComposing && event.key !== Qt.Key_Escape)
            return;

        if (event.key === Qt.Key_Escape) {
            root.close();
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            wallpaperPath.decrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            wallpaperPath.incrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            const list = root.filteredWallpapers;
            if (wallpaperPath.currentIndex >= 0 && wallpaperPath.currentIndex < list.length)
                Wallpapers.setWallpaper(list[wallpaperPath.currentIndex]);
            event.accepted = true;
        }
    }

    // 方案切换按钮
    component SchemeButton: Rectangle {
        id: schemeBtn

        property string label: ""
        property string icon: ""
        property bool checked: false

        signal clicked()

        implicitWidth: labelItem.implicitWidth + iconItem.implicitWidth + 26
        implicitHeight: 28
        radius: 10
        color: checked ? Qt.alpha(Theme.mauve, 0.18) : schemeBtnArea.containsMouse ? Theme.surface1 : Theme.surface0
        border.width: checked ? 1 : 0
        border.color: Qt.alpha(Theme.mauve, 0.5)

        RowLayout {
            anchors.centerIn: parent
            spacing: 5

            MaterialSymbol {
                id: iconItem

                text: schemeBtn.icon
                size: 14
                color: checked ? Theme.mauve : Theme.subtext1
            }
            StyledText {
                id: labelItem

                text: schemeBtn.label
                font.pixelSize: Config.appearance.fonts.size.small
                color: checked ? Theme.mauve : Theme.subtext1
            }
        }

        MouseArea {
            id: schemeBtnArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: schemeBtn.clicked()
        }

        Behavior on color {
            ColorAnim {}
        }
    }

    // 预设 chip：色点 + 名称，hover 时可把当前壁纸绑定给该主题
    component PresetChip: Rectangle {
        id: chip

        required property QtObject preset

        readonly property bool active: Theme.presetName === chip.preset.presetId
        readonly property string assignedWallpaper: Theme.presetWallpaper(chip.preset.presetId)

        implicitWidth: chipRow.implicitWidth + 20
        implicitHeight: 30
        radius: 10
        color: active ? Qt.alpha(chip.preset.mauve, 0.18) : chipArea.containsMouse ? Theme.surface1 : Theme.surface0
        border.width: active ? 1 : 0
        border.color: Qt.alpha(chip.preset.mauve, 0.5)

        RowLayout {
            id: chipRow

            anchors.centerIn: parent
            spacing: 6

            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: chip.preset.mauve
            }

            StyledText {
                text: chip.preset.displayName
                color: active ? chip.preset.mauve : Theme.subtext1
            }

            // 已绑定壁纸标记 / 绑定操作
            MaterialSymbol {
                text: chip.assignedWallpaper !== "" ? "photo_library" : "add_photo_alternate"
                size: 13
                color: pinArea.containsMouse ? Theme.mauve : Theme.overlay0

                MouseArea {
                    id: pinArea

                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (Paths.currentWallpaper)
                            Theme.assignCurrentWallpaperToPreset(chip.preset.presetId);
                    }
                }

                StyledTooltip {
                    content: chip.assignedWallpaper !== ""
                        ? "已绑定：" + (chip.assignedWallpaper.split('/').pop() || "壁纸") + "，点击用当前壁纸替换"
                        : "把当前壁纸绑定给该主题"
                    alternativeVisibleCondition: pinArea.containsMouse
                }
            }
        }

        MouseArea {
            id: chipArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Theme.usePreset(chip.preset.presetId)
        }

        Behavior on color {
            ColorAnim {}
        }
    }
}
