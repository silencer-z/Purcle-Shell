import "../widgets"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.services
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
    property string filterText: ""

    readonly property int intrinsicHeight: calculateContentHeight()

    function focusInput() {
        searchField.forceActiveFocus();
        Qt.inputMethod.show();
        searchField.selectAll();
    }

    function close() {
        root.currentIndex = 0;
        searchField.clear();
        root.filterText = "";
        Visibilities.launcher = false;
    }

    function executeApp(entry) {
        AppModel.trackApp(entry.name || entry.id);
        entry.execute();
        Visibilities.launcher = false;
    }

    function executeAction(action) {
        action.execute();
        Visibilities.launcher = false;
    }

    function calculateContentHeight() {
        var totalHeight = 90;
        var itemCount = filteredApps.count;
        if (itemCount === 0)
            return 90;

        for (var i = 0; i < itemCount; i++) {
            var item = filteredApps.values[i];
            if (item && item.isHeader)
                totalHeight += 32;
            else if (item)
                totalHeight += 60;
            totalHeight += 2;
        }
        totalHeight += 15;
        return Math.max(90, Math.min(totalHeight, Config.appearance.sizes.maxPanelHeight));
    }

    implicitWidth: Config.appearance.sizes.panelBottom
    implicitHeight: Math.min(root.intrinsicHeight, root.maxHeight)

    Keys.onPressed: (event) => {
        if (searchField.inputMethodComposing && event.key !== Qt.Key_Escape)
            return;

        if (event.key === Qt.Key_Escape) {
            root.close();
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            if (root.currentIndex > 0) {
                root.currentIndex--;
                listView.currentIndex = root.currentIndex;
                listView.positionViewAtIndex(root.currentIndex, ListView.Contain);
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            if (root.currentIndex < filteredApps.count - 1) {
                root.currentIndex++;
                listView.currentIndex = root.currentIndex;
                listView.positionViewAtIndex(root.currentIndex, ListView.Contain);
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (root.currentIndex >= 0 && root.currentIndex < filteredApps.count) {
                var entry = filteredApps.values[root.currentIndex];
                root.executeApp(entry.entry);
            }
            event.accepted = true;
        }
    }

    ScriptModel {
        id: filteredApps

        objectProp: "id"
        property int count: values ? values.length : 0
        values: AppModel.matching(root.filterText)
    }

    AppListView {
        id: listView

        model: filteredApps
        searchQuery: root.filterText
        currentIndex: root.currentIndex
        onExecuteApp: (entry) => {
            return root.executeApp(entry);
        }
        onExecuteAction: (action) => {
            return root.executeAction(action);
        }
        onIndexChanged: (index) => {
            return root.currentIndex = index;
        }

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: searchBar.top
            margins: Config.appearance.padding.large
        }

    }

    Rectangle {
        id: searchBar

        height: Config.appearance.sizes.searchBar
        radius: Config.appearance.rounding.small
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Config.appearance.padding.large
        color: searchField.activeFocus ? Theme.surface1 : Theme.surface0
        border.width: 1
        border.color: searchField.activeFocus ? Theme.mauve : Theme.surface2

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
                color: searchField.activeFocus ? Theme.mauve : Theme.overlay0

                Behavior on color {
                    ColorAnim {}
                }
            }

            StyledTextInput {
                id: searchField

                function clear() {
                    text = "";
                }

                focus: true
                Layout.fillWidth: true
                font.pixelSize: Config.appearance.fonts.size.normal
                color: Theme.text
                    onTextChanged: {
                        root.filterText = text;
                    }
            }
        }
    }
}
