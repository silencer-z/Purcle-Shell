import "./widgets"
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services

Item {
    id: root

    required property var panelWrapper
    property int currentIndex: 0

    // 提供给管理器的关闭函数
    function close() {
        root.currentIndex = 0;
        searchField.clear();
        AppModel.filterText = "";
    }

    // 关闭部件由管理器执行
    function executeApp(entry) {
        AppModel.trackApp(entry.name || entry.id);
        entry.execute();
        panelWrapper.close();
    }

    function executeAction(action) {
        action.execute();
        panelWrapper.close();
    }

    function calculateContentHeight() {
        var totalHeight =90;
        var itemCount = AppModel.appModel.count;
        if (itemCount === 0)
            return 90;

        for (var i = 0; i < itemCount; i++) {
            var item = AppModel.appModel.values[i];
            if (item && item.isHeader)
                totalHeight += 32;
            else if (item)
                totalHeight += 60;
            totalHeight += 2;
        }
        totalHeight += 15;
        return Math.max(90, Math.min(totalHeight, 725));
    }

    implicitWidth: 600
    implicitHeight: calculateContentHeight()
    Component.onCompleted: {
        searchField.forceActiveFocus();
    }
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            panelWrapper.close();
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            if (root.currentIndex > 0) {
                root.currentIndex--;
                listView.currentIndex = root.currentIndex;
                listView.positionViewAtIndex(root.currentIndex, ListView.Contain);
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            if (root.currentIndex < AppModel.appModel.count - 1) {
                root.currentIndex++;
                listView.currentIndex = root.currentIndex;
                listView.positionViewAtIndex(root.currentIndex, ListView.Contain);
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (root.currentIndex >= 0 && root.currentIndex < AppModel.appModel.count) {
                var entry = AppModel.appModel.values[root.currentIndex];
                root.executeApp(entry.entry);
            }
            event.accepted = true;
        }
    }

    AppListView {
        id: listView

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
            margins: 15
        }

    }

    Rectangle {
        id: searchBar

        height: 60
        radius: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 15
        color: "#313244"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            IconText {
                text: "search"
                size: 24
                color: "#cdd6f4"
            }

            StyledTextInput {
                id: searchField

                function clear() {
                    text = "";
                }

                focus: true
                Layout.fillWidth: true
                color: "#cdd6f4"
                onTextChanged: {
                    AppModel.filterText = text;
                }
            }
        }
    }
}
