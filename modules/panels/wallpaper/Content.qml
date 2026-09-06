import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.Configs
import qs.services

ClippingRectangle {
    id: root

    required property int maxHeight

    radius: Config.appearance.border.rounding
    topLeftRadius: Config.appearance.border.rounding
    topRightRadius: Config.appearance.border.rounding
    bottomLeftRadius: 0
    bottomRightRadius: 0
    color: "transparent"

    readonly property int intrinsicHeight: 420

    function close() {
        Visibilities.wallpaper = false;
    }

    function focusInput() {
        wallpaperPath.forceActiveFocus();
    }

    implicitWidth: 1150
    implicitHeight: Math.min(root.intrinsicHeight, root.maxHeight)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // ==== 标题栏 ====
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            StyledText {
                text: "壁纸选择"
                font.pixelSize: 16
                font.bold: true
                color: Theme.text
            }

            StyledText {
                text: Wallpapers.currentWallpaperName || "未设置"
                font.pixelSize: 13
                color: Theme.overlay0
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.maximumWidth: 300
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
                        font.pixelSize: 12
                        color: Theme.text
                    }
                }

                MouseArea {
                    id: randomBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Wallpapers.setRandom()
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
                    font.pixelSize: 13
                    color: Theme.text
                    text: Wallpapers.searchQuery
                    onTextChanged: Wallpapers.searchQuery = text
                    Keys.onEscapePressed: {
                        if (searchInput.text) {
                            searchInput.text = "";
                        } else {
                            root.close();
                        }
                    }
                }

                MaterialSymbol {
                    text: Wallpapers.searchQuery ? "close" : ""
                    size: 16
                    color: Theme.overlay0
                    visible: Wallpapers.searchQuery !== ""
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
                font.pixelSize: 13
                color: Theme.text
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
                        font.pixelSize: 12
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

            readonly property real unitWidth: width / 5

            model: ScriptModel {
                values: Wallpapers.filteredWallpaperList
            }
            pathItemCount: 3
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            clip: true
            focus: true
            cacheItemCount: 5

            // 当前壁纸居中
            onModelChanged: {
                const idx = model.values.indexOf(Wallpapers.currentWallpaper);
                currentIndex = idx !== -1 ? idx : (model.count > 0 ? 0 : 0);
            }
            Component.onCompleted: {
                function trySetIndex() {
                    if (Wallpapers.wallpaperList.length > 0) {
                        const idx = Wallpapers.wallpaperList.indexOf(Wallpapers.currentWallpaper);
                        currentIndex = idx !== -1 ? idx : 0;
                    } else {
                        Qt.callLater(trySetIndex);
                    }
                }
                trySetIndex();
            }

            path: Path {
                startX: 0
                startY: wallpaperPath.height / 2

                PathLine {
                    x: wallpaperPath.width
                    y: wallpaperPath.height / 2
                }
            }

            delegate: Item {
                id: delegateItem

                required property var modelData
                required property int index

                readonly property bool isCurrent: PathView.isCurrentItem
                readonly property bool isApplied: modelData === Wallpapers.currentWallpaper

                implicitWidth: isCurrent ? wallpaperPath.unitWidth * 3 : wallpaperPath.unitWidth * 2
                implicitHeight: wallpaperPath.height

                z: isCurrent ? 100 : 1
                opacity: isCurrent ? 1.0 : 0.85

                Behavior on implicitWidth {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                Rectangle {
                    id: cardRect
                    anchors.centerIn: parent
                    implicitWidth: parent.width - (delegateItem.isCurrent ? Math.max(20, wallpaperPath.unitWidth * 1) : Math.max(10, wallpaperPath.unitWidth * 0.5))
                    implicitHeight: parent.height
                    scale: delegateItem.isCurrent ? 1 : 0.8
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
                            font.pixelSize: 11
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
                    Behavior on scale {
                        NumberAnimation { duration: Config.appearance.animations.durations.normal; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            root.close();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            wallpaperPath.decrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            wallpaperPath.incrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            const list = Wallpapers.filteredWallpaperList;
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
                font.pixelSize: 12
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

    // 预设 chip：色点 + 名称；hover 时可把当前壁纸绑定给该主题
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
                font.pixelSize: 12
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
