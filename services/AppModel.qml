pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string filterText: ""
    property string sortMode: "frequency"
    property var hiddenApps:["electron34","CMake","electron37","btop++","键盘布局测试器","qv4l2","qvidcap","lstopo"]

    function getFilteredAndSortedApps() {
        var apps = DesktopEntries.applications.values.filter(entry => {

            if (root.hiddenApps.indexOf(entry.id) !== -1
                || root.hiddenApps.indexOf(entry.name) !== -1) {
                return false;
            }

            var searchText = filterText.toLowerCase();
            if (searchText === "")
                return true;

            return entry.name.toLowerCase().indexOf(searchText) !== -1 
            || (entry.genericName && entry.genericName.toLowerCase().indexOf(searchText) !== -1) 
            || (entry.comment && entry.comment.toLowerCase().indexOf(searchText) !== -1) 
            || (entry.keywords && entry.keywords.some(keyword => keyword.toLowerCase().indexOf(searchText) !== -1));
        });

        if (sortMode === "name") {
            apps.sort((a, b) => a.name.localeCompare(b.name));
        } else if (sortMode === "frequency") {
            apps = sortByFrequency(apps);
        }

        return apps.map(entry => {
            var searchText = filterText.toLowerCase();
            var highlightedName = entry.name;
            if (searchText !== "") {
                highlightedName = entry.name.replace(new RegExp(searchText, "ig"), `<span style="color: #705511;">$&</span>`);
            }

            return {
                "id": entry.id,
                "isHeader": false,
                "name": entry.name,
                "genericName": entry.genericName,
                "comment": entry.comment,
                "icon": entry.icon,
                "categories": entry.categories,
                "actions": entry.actions,
                "highlightedName": highlightedName,
                "entry": entry,
            };
        });
        
    }

    ScriptModel {
        id: model
        objectProp: "id"
        property int count: values ? values.length : 0
        values: root.getFilteredAndSortedApps()
    }

    readonly property alias appModel: model

    property bool dataReady: false

    FileView {
        id: frequencyFile
        path: Quickshell.cacheDir+ "/app_freq.json"
        watchChanges: false
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        blockLoading: false
        preload: true

        adapter: JsonAdapter {
            id: adapter
            property var apps: ({})
            property string lastUpdateTime: ""
            onAppsChanged: root.dataReady = true
        }

        onLoadFailed: function (error) {
            if (error.code === FileViewError.FileNotFound) {
                adapter.apps = {};
                adapter.lastUpdateTime = new Date().toISOString();
                writeAdapter();
            }
            root.dataReady = true;
        }

        onLoaded: {
            root.dataReady = true;
        }
    }

    function trackApp(appName) {
        if (!appName || !dataReady)
            return;

        var apps = frequencyFile.adapter.apps || {};
        apps[appName] = (apps[appName] || 0) + 1;
        frequencyFile.adapter.apps = apps;
        frequencyFile.adapter.lastUpdateTime = new Date().toISOString();
    }

    function getCount(appName) {
        if (!dataReady)
            return 0;

        var apps = frequencyFile.adapter.apps || {};
        return apps[appName] || 0;
    }

    function sortByFrequency(apps) {
        if (!dataReady)
            return apps;

        return apps.slice().sort((a, b) => {
            var countA = getCount(a.name || a.id);
            var countB = getCount(b.name || b.id);
            return countB - countA;
        });
    }
}