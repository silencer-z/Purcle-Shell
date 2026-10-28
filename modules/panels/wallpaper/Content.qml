import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
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
    readonly property int bodyWidth: Config.appearance.sizes.panelSide

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
            spacing: Config.appearance.spacing.small

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

            RowLayout {
                id: recolorRow

                spacing: Config.appearance.spacing.smaller

                MaterialSymbol {
                    text: "format_color_fill"
                    size: Config.appearance.fonts.size.small
                    color: Config.wallpaper.recolor ? Theme.mauve : Theme.overlay0
                }
                StyledText {
                    text: "着色"
                    font.pixelSize: Config.appearance.fonts.size.small
                    color: Config.wallpaper.recolor ? Theme.mauve : Theme.subtext1
                }
                StyledSwitch {
                    checked: Config.wallpaper.recolor
                    onToggled: next => Config.wallpaper.recolor = next
                }

                HoverHandler {
                    id: recolorHover
                }

                StyledTooltip {
                    content: Config.wallpaper.recolor
                        ? "按当前主题着色壁纸。动态主题会冻结上次提取的颜色。"
                        : "关闭后使用原图。动态主题会从壁纸重新取色。"
                    alternativeVisibleCondition: recolorHover.hovered
                }
            }

            // 随机按钮
            Rectangle {
                Layout.preferredWidth: randomRow.implicitWidth + Config.appearance.padding.normal * 2
                Layout.preferredHeight: Config.appearance.sizes.chipRow
                radius: Config.appearance.rounding.small
                color: randomBtn.containsMouse ? Theme.surface1 : Theme.surface0
                border.width: 1
                border.color: Theme.surface2

                RowLayout {
                    id: randomRow

                    anchors.centerIn: parent
                    spacing: Config.appearance.spacing.smaller

                    MaterialSymbol {
                        text: "shuffle"
                        size: Config.appearance.fonts.size.small
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
            Layout.preferredHeight: Config.appearance.sizes.searchBar - Config.appearance.padding.large
            radius: Config.appearance.rounding.small
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
                anchors.margins: Config.appearance.padding.normal
                spacing: Config.appearance.spacing.small

                MaterialSymbol {
                    text: "search"
                    size: Config.appearance.fonts.size.large
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

        // ==== 配色：预设与动态主题并列，始终展开 ====
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Config.appearance.spacing.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Config.appearance.spacing.small

                MaterialSymbol {
                    text: "palette"
                    size: Config.appearance.fonts.size.large
                    color: Theme.overlay0
                }

                StyledText {
                    text: "配色"
                    font.pixelSize: Config.appearance.fonts.size.medium
                    color: Theme.overlay0
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible: Theme.scheme === "matugen"
                    Layout.preferredHeight: Config.appearance.sizes.chipRow
                    Layout.preferredWidth: darkBtnLayout.implicitWidth + Config.appearance.padding.normal * 2
                    radius: Config.appearance.rounding.small
                    color: darkBtn.containsMouse ? Theme.surface1 : Theme.surface0
                    border.width: 1
                    border.color: Config.colors.isDarkMode ? Theme.surface2 : Theme.mauve

                    RowLayout {
                        id: darkBtnLayout

                        anchors.centerIn: parent
                        spacing: Config.appearance.spacing.smaller

                        MaterialSymbol {
                            text: Config.colors.isDarkMode ? "dark_mode" : "light_mode"
                            size: Config.appearance.fonts.size.small
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
            }

            Flow {
                Layout.fillWidth: true
                spacing: Config.appearance.spacing.small

                Repeater {
                    model: Theme.presets

                    ThemeChip {
                        required property QtObject modelData

                        label: modelData.displayName
                        accent: modelData.mauve
                        active: Theme.scheme === "preset" && Theme.presetName === modelData.presetId
                        onClicked: Theme.usePreset(modelData.presetId)
                    }
                }

                ThemeChip {
                    label: "动态"
                    icon: "auto_awesome"
                    accent: Color.mauve
                    active: Theme.scheme === "matugen"
                    onClicked: Theme.useMatugen()
                }
            }
        }

        // ==== 壁纸轮播 ====
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: Config.appearance.sizes.listMin

            Rectangle {
                anchors.fill: parent
                radius: Config.appearance.rounding.small
                color: Theme.surface0

                Behavior on color {
                    ColorAnim {}
                }
            }

            PathView {
                id: wallpaperPath

                anchors.fill: parent

            // 卡片 8:5，聚焦项略大
            readonly property real focusedWidth: width * 0.89
            readonly property real normalWidth: width * 0.86
            readonly property real aspectRatio: 5 / 8
            readonly property real normalCardHeight: normalWidth * aspectRatio
            readonly property real focusedCardHeight: focusedWidth * aspectRatio
            readonly property real itemStride: focusedCardHeight + Config.appearance.spacing.smaller
            // 按实际卡片高度推算路径上能容纳的奇数项，避免重叠
            readonly property int visibleCount: {
                if (height <= 0 || itemStride <= 0)
                    return 1;
                let n = Math.floor(height / itemStride);
                if (n < 1)
                    return 1;
                if (n % 2 === 0)
                    n -= 1;
                const total = model?.count ?? 0;
                if (total > 0)
                    n = Math.min(n, total);
                return n;
            }

            model: ScriptModel {
                values: root.filteredWallpapers
            }
            pathItemCount: Math.max(1, wallpaperPath.visibleCount)
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            clip: true
            focus: true
            cacheItemCount: 5

            // 当前壁纸居中（列表异步加载完成后 onModelChanged 会再触发一次，无需重试循环）
            onModelChanged: Qt.callLater(() => {
                const vals = model?.values ?? [];
                const idx = vals.indexOf(Wallpapers.currentWallpaper);
                wallpaperPath.currentIndex = idx !== -1 ? idx : 0;
            })

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
                // 8:5 卡片，聚焦项略大
                readonly property real cardWidth: isCurrent ? wallpaperPath.focusedWidth : wallpaperPath.normalWidth
                readonly property real cardHeight: cardWidth * wallpaperPath.aspectRatio

                width: wallpaperPath.width
                height: cardHeight

                z: isCurrent ? 100 : 1
                opacity: isCurrent ? 1.0 : 0.75

                Behavior on height {
                    NumberAnimation {
                        duration: Config.appearance.animations.durations.emphasizedAccel
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.appearance.animations.durations.emphasizedAccel
                        easing.type: Easing.OutCubic
                    }
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: delegateItem.cardWidth
                    height: delegateItem.cardHeight

                    ClippingRectangle {
                        id: cardRect

                        anchors.fill: parent
                        radius: Config.appearance.rounding.normal
                        color: Theme.surface0

                        Image {
                            anchors.fill: parent
                            source: "file://" + delegateItem.modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Config.appearance.rounding.normal
                        color: "transparent"
                        border.width: Config.appearance.border.thickness
                        border.color: delegateItem.isCurrent ? Theme.mauve : Theme.blue

                        Behavior on border.color {
                            ColorAnim {}
                        }
                    }

                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: Config.appearance.padding.normal
                        width: appliedText.width + Config.appearance.padding.normal
                        height: Config.appearance.sizes.actionHeight - 4
                        radius: Config.appearance.rounding.small / 2
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

                    Behavior on width {
                        NumberAnimation {
                            duration: Config.appearance.animations.durations.normal
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on height {
                        NumberAnimation {
                            duration: Config.appearance.animations.durations.normal
                            easing.type: Easing.OutCubic
                        }
                    }
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

    component ThemeChip: Rectangle {
        id: chip

        property string label: ""
        property string icon: ""
        property color accent: Theme.mauve
        property bool active: false

        signal clicked()

        implicitWidth: chipRow.implicitWidth + Config.appearance.padding.normal * 2
        implicitHeight: Config.appearance.sizes.chipRow
        radius: Config.appearance.rounding.small
        color: active ? Qt.alpha(chip.accent, 0.18) : chipArea.containsMouse ? Theme.surface1 : Theme.surface0
        border.width: active ? 1 : 0
        border.color: Qt.alpha(chip.accent, 0.5)

        RowLayout {
            id: chipRow

            anchors.centerIn: parent
            spacing: Config.appearance.spacing.smaller

            MaterialSymbol {
                visible: chip.icon !== ""
                text: chip.icon
                size: Config.appearance.fonts.size.small
                color: chip.active ? chip.accent : Theme.subtext1
            }

            Rectangle {
                visible: chip.icon === ""
                width: Config.appearance.spacing.normal
                height: Config.appearance.spacing.normal
                radius: Config.appearance.spacing.normal / 2
                color: chip.accent
            }

            StyledText {
                text: chip.label
                font.pixelSize: Config.appearance.fonts.size.small
                color: chip.active ? chip.accent : Theme.subtext1
            }
        }

        MouseArea {
            id: chipArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }

        Behavior on color {
            ColorAnim {}
        }
    }
}
