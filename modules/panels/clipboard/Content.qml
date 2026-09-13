pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.components
import qs.Configs

ClippingRectangle {
    id: root

    required property int maxHeight

    radius: Config.appearance.border.rounding
    topLeftRadius: Config.appearance.border.rounding
    topRightRadius: Config.appearance.border.rounding
    bottomLeftRadius: 0
    bottomRightRadius: 0
    color: "transparent"

    property int currentIndex: 0
    property string searchText: ""

    readonly property int panelPadding: Config.appearance.padding.large
    readonly property int itemHeight: Config.appearance.sizes.listItem
    readonly property int searchHeight: Config.appearance.sizes.searchBar
    readonly property int headerHeight: Config.appearance.sizes.header

    readonly property int listAreaHeight: Math.max(
        Config.appearance.sizes.listMin,
        filterModel.count * itemHeight + Math.max(0, filterModel.count - 1) * Config.appearance.spacing.smaller
    )

    readonly property int intrinsicHeight: {
        const body = headerHeight + searchHeight + listAreaHeight + root.panelPadding * 2 + Config.appearance.spacing.normal * 2;
        return Math.min(
            Config.appearance.sizes.maxPanelHeight,
            Math.max(Config.appearance.sizes.panelBottomMin, body)
        );
    }

    function focusInput() {
        searchText = "";
        updateFilter();
        list.forceActiveFocus();
        searchInput.forceActiveFocus();
        currentIndex = 0;
    }


    function close() {
        currentIndex = 0;
        searchText = "";
        Visibilities.clipboard = false;
    }

    implicitWidth: Config.appearance.sizes.panelBottom
    implicitHeight: Math.min(root.intrinsicHeight, root.maxHeight)

    ListModel {
        id: filterModel
    }

    function updateFilter() {
        filterModel.clear();
        const query = searchText.toLowerCase().trim();
        const pinned = [];
        const unpinned = [];
        for (let i = 0; i < ClipModel.itemModel.count; i++) {
            const item = ClipModel.itemModel.get(i);
            if (item.pinned) {
                pinned.push(item);
            } else if (!query || item.preview.toLowerCase().includes(query)) {
                unpinned.push(item);
            }
        }
        pinned.forEach(item => filterModel.append(item));
        unpinned.forEach(item => filterModel.append(item));
    }

    onSearchTextChanged: updateFilter()

    Connections {
        target: ClipModel.itemModel
        function onCountChanged(): void {
            updateFilter();
        }
    }

    Connections {
        target: Visibilities
        function onClipboardChanged(): void {
            if (Visibilities.clipboard) {
                ClipModel.refresh();
                updateFilter();
            }
        }
    }

    Keys.onPressed: (event) => {
        if (searchInput.inputMethodComposing && event.key !== Qt.Key_Escape)
            return;

        if (event.key === Qt.Key_Escape) {
            if (searchText) {
                searchText = "";
            } else {
                root.close();
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            if (currentIndex > 0) {
                currentIndex--;
                list.currentIndex = currentIndex;
                list.positionViewAtIndex(currentIndex, ListView.Contain);
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            if (currentIndex < filterModel.count - 1) {
                currentIndex++;
                list.currentIndex = currentIndex;
                list.positionViewAtIndex(currentIndex, ListView.Contain);
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            const item = filterModel.get(currentIndex);
            if (item) {
                ClipModel.copy(item);
                root.close();
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Delete) {
            const item = filterModel.get(currentIndex);
            if (item) {
                ClipModel.deleteItem(item);
                updateFilter();
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_P) {
            const item = filterModel.get(currentIndex);
            if (item) {
                ClipModel.togglePin(item.id);
                ClipModel.refresh();
                updateFilter();
            }
            event.accepted = true;
        }
    }

    RowLayout {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.panelPadding
        height: root.headerHeight
        spacing: Config.appearance.spacing.small

        Rectangle {
            Layout.preferredWidth: Config.appearance.sizes.icon
            Layout.preferredHeight: Config.appearance.sizes.icon
            radius: Config.appearance.sizes.iconRadius
            color: Theme.surface0

            MaterialSymbol {
                anchors.centerIn: parent
                text: "content_paste"
                size: Config.appearance.fonts.size.large
                color: Theme.mauve
            }
        }

        StyledText {
            text: qsTr("剪贴板")
            font.pixelSize: Config.appearance.fonts.size.large
            font.bold: true
            color: Theme.text
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.preferredWidth: Config.appearance.sizes.icon
            Layout.preferredHeight: Config.appearance.sizes.icon
            radius: Config.appearance.sizes.iconRadius
            color: clearArea.containsMouse ? Qt.alpha(Theme.danger, 0.8) : Theme.surface1
            enabled: filterModel.count > 0
            opacity: enabled ? 1 : 0.5

            Behavior on color {
                ColorAnim {}
            }

            MaterialSymbol {
                anchors.centerIn: parent
                text: "delete_sweep"
                size: 18
                color: filterModel.count > 0 ? Theme.danger : Theme.subtext1
            }

            MouseArea {
                id: clearArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Quickshell.execDetached(["cliphist", "wipe"]);
                    ClipModel.refresh();
                    updateFilter();
                }
            }

            StyledTooltip {
                content: qsTr("清空全部")
                alternativeVisibleCondition: clearArea.containsMouse
            }
        }
    }

    ListView {
        id: list

        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: searchBar.top
        anchors.leftMargin: root.panelPadding
        anchors.rightMargin: root.panelPadding
        anchors.topMargin: Config.appearance.spacing.small
        anchors.bottomMargin: Config.appearance.spacing.small

        highlightFollowsCurrentItem: true
        highlightMoveDuration: Config.appearance.animations.durations.emphasizedAccel
        clip: true
        spacing: Config.appearance.spacing.smaller
        boundsBehavior: Flickable.StopAtBounds
        model: filterModel
        currentIndex: root.currentIndex
        focus: true

        delegate: Item {
            id: clipRow

            required property string id
            required property string preview
            required property string type
            required property bool pinned
            required property bool cached
            required property string imagePath

            readonly property var entry: ({
                id: clipRow.id,
                preview: clipRow.preview,
                type: clipRow.type,
                pinned: clipRow.pinned,
                cached: clipRow.cached,
                imagePath: clipRow.imagePath
            })

            width: list.width
            height: root.itemHeight

            Rectangle {
                anchors.fill: parent
                radius: Config.appearance.rounding.small
                color: ListView.isCurrentItem ? Theme.surface0 : clipRow.pinned ? Theme.surface0 : "transparent"

                Behavior on color {
                    ColorAnim {}
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: Config.appearance.padding.normal
                spacing: Config.appearance.spacing.small

                Rectangle {
                    Layout.preferredWidth: Config.appearance.sizes.icon
                    Layout.preferredHeight: Config.appearance.sizes.icon
                    radius: Config.appearance.rounding.small
                    color: Theme.surface1
                    clip: true
                    Layout.alignment: Qt.AlignVCenter

                    Image {
                        visible: clipRow.type === "image" && clipRow.cached
                        anchors.fill: parent
                        source: clipRow.imagePath || ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                    }

                    MaterialSymbol {
                        visible: !(clipRow.type === "image" && clipRow.cached)
                        anchors.centerIn: parent
                        text: {
                            if (clipRow.type === "image")
                                return "image";
                            if (clipRow.type === "file")
                                return "draft";
                            return "notes";
                        }
                        size: Config.appearance.fonts.size.large
                        color: Theme.subtext1
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    StyledText {
                        anchors.fill: parent
                        anchors.margins: Config.appearance.padding.smaller
                        text: {
                            if (clipRow.type === "file")
                                return decodeURIComponent(clipRow.preview.replace("file://", ""));
                            if (clipRow.type === "image")
                                return clipRow.cached ? qsTr("图片") : qsTr("加载中…");
                            return clipRow.preview;
                        }
                        color: Theme.text
                        font.pixelSize: Config.appearance.fonts.size.normal
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        maximumLineCount: 2
                    }
                }

                Rectangle {
                    Layout.preferredWidth: Config.appearance.sizes.actionHeight + Config.appearance.padding.larger
                    Layout.preferredHeight: Config.appearance.sizes.actionHeight
                    radius: Config.appearance.rounding.small / 2
                    color: clipRow.pinned ? Theme.peach : Theme.surface1
                    Layout.alignment: Qt.AlignVCenter

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: clipRow.pinned ? "keep" : "keep_off"
                        size: Config.appearance.fonts.size.large
                        color: clipRow.pinned ? Theme.onPrimary : Theme.text
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            ClipModel.togglePin(clipRow.id);
                            ClipModel.refresh();
                            updateFilter();
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: list.currentIndex = index
                onClicked: {
                    ClipModel.copy(clipRow.entry);
                    root.close();
                }
            }
        }

        StyledText {
            visible: parent.count === 0
            anchors.centerIn: parent
            text: searchText ? qsTr("无匹配结果") : qsTr("暂无剪贴板历史")
            color: Theme.overlay0
            font.pixelSize: Config.appearance.fonts.size.normal
        }
    }

    Rectangle {
        id: searchBar

        height: root.searchHeight
        radius: Config.appearance.rounding.small
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: root.panelPadding
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
                size: Config.appearance.fonts.size.icon
                color: searchInput.activeFocus ? Theme.mauve : Theme.overlay0

                Behavior on color {
                    ColorAnim {}
                }
            }

            StyledTextInput {
                id: searchInput

                Layout.fillWidth: true
                focus: true
                font.pixelSize: Config.appearance.fonts.size.normal
                color: Theme.text
                onTextChanged: {
                    searchText = text;
                }
                Keys.onEscapePressed: {
                    if (searchText) {
                        searchText = "";
                    } else {
                        root.close();
                    }
                }
            }
        }
    }
}
