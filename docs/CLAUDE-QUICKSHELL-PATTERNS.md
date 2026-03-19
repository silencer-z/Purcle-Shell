# Quickshell Development Patterns and Best Practices

This document covers common development patterns, best practices, and architectural approaches for Quickshell development.

## Service Pattern

The singleton service pattern is fundamental for system integration and reusable functionality.

### Basic Service Structure
```qml
// services/Battery.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: service

    // Public properties
    property int level: 0
    property bool charging: false
    property string status: "Unknown"

    // Private process - declare once, reuse via running property
    Process {
        id: batteryProcess
        running: false
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity"]

        stdout: SplitParser {
            onRead: data => {
                service.level = parseInt(data.trim());
                service.updateStatus();
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                // Schedule next check
                restartTimer.restart();
            } else {
                console.error("Battery check failed:", exitCode);
            }
        }
    }

    Process {
        id: statusProcess
        running: false
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/status"]

        stdout: SplitParser {
            onRead: data => {
                const statusStr = data.trim().toLowerCase();
                service.charging = statusStr === "charging";
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                restartTimer.restart();
            }
        }
    }

    // Timer for periodic updates
    Timer {
        id: restartTimer
        interval: 30000 // 30 seconds
        onTriggered: service.update()
    }

    // Public methods
    function update() {
        batteryProcess.running = true;
        statusProcess.running = true;
    }

    function updateStatus() {
        if (charging) {
            status = "Charging";
        } else if (level > 80) {
            status = "Good";
        } else if (level > 20) {
            status = "Low";
        } else {
            status = "Critical";
        }
    }

    // Initialize on startup
    Component.onCompleted: update()
}
```

### Service Usage
```qml
import "../services"

Battery {
    id: batteryService
}

// In component
Text {
    text: `${batteryService.level}% (${batteryService.status})`
    color: batteryService.level < 20 ? "#f38ba8" : "#cdd6f4"
}
```

## Component Architecture

### Panel Component Pattern
```qml
// modules/bar/Bar.qml
import QtQuick
import Quickshell

PanelWindow {
    id: bar

    // Configuration
    height: 30
    anchors {
        top: true
        left: true
        right: true
    }

    // Public API
    property alias workspaces: workspaceRepeater.model
    property alias systemTray: systemTray

    // Content
    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 15

        // Left side
        WorkspacesWidget {
            id: workspaceWidget
            anchors.verticalCenter: parent.verticalCenter
        }

        // Center (flexible space)
        Item { Layout.fillWidth: true }

        // Right side
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            BatteryWidget {}
            NetworkWidget {}
            VolumeWidget {}
            ClockWidget {}
        }
    }
}
```

### Widget Component Pattern
```qml
// components/BatteryWidget.qml
import QtQuick
import "../services"

Rectangle {
    id: widget

    property int batteryLevel: Battery.level
    property bool isCharging: Battery.charging

    width: content.width + 10
    height: 24

    color: "transparent"

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 5

        StyledIcon {
            icon.name: isCharging ? "battery-charging" : "battery"
            color: batteryLevel < 20 ? "#f38ba8" : "#cdd6f4"
            size: 16
        }

        StyledText {
            text: `${batteryLevel}%`
            color: batteryLevel < 20 ? "#f38ba8" : "#cdd6f4"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Show battery details or launch power settings
            showBatteryDetails();
        }
    }
}
```

## Panel Management Pattern

### Panel Wrapper with State Machine
```qml
// components/PanelWrapper.qml
import QtQuick

Rectangle {
    id: wrapper

    property Component contentComponent
    property var contentProperties: ({})
    property alias content: contentLoader.item

    // State machine
    state: "closed"

    states: [
        State {
            name: "closed"
            PropertyChanges { target: wrapper; visible: false }
            PropertyChanges { target: contentLoader; active: false }
        },
        State {
            name: "loading"
            PropertyChanges { target: wrapper; visible: true }
            PropertyChanges { target: contentLoader; active: true }
        },
        State {
            name: "open"
            PropertyChanges { target: wrapper; visible: true }
            PropertyChanges { target: contentLoader; active: true }
        },
        State {
            name: "closing"
            PropertyChanges { target: wrapper; visible: true }
            PropertyChanges { target: contentLoader; active: true }
        }
    ]

    transitions: [
        Transition {
            from: "closed"; to: "loading"
            ScriptAction { script: wrapper.state = "open" }
        },
        Transition {
            from: "open"; to: "closing"
            SequentialAnimation {
                ScriptAction { script: closingAnimation.start() }
                PropertyAnimation { target: wrapper; opacity: 0; duration: 200 }
                ScriptAction { script: wrapper.state = "closed" }
                PropertyAnimation { target: wrapper; opacity: 1; duration: 0 }
            }
        }
    ]

    // Content loader
    Loader {
        id: contentLoader
        active: false
        sourceComponent: contentComponent
        property var properties: contentProperties
    }

    // Public API
    function open(component, properties = {}) {
        if (state !== "closed") return;

        contentComponent = component;
        contentProperties = properties;
        state = "loading";
    }

    function close() {
        if (state === "open") {
            state = "closing";
        }
    }

    // Animations
    PropertyAnimation {
        id: closingAnimation
        target: wrapper
        property: "opacity"
        to: 0
        duration: 200
    }
}
```

## Multi-Screen Support Pattern

### Screen-Aware Components
```qml
// shell.qml
import QtQuick
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {
            required property ShellScreen modelData

            // Main bar for each screen
            Bar {
                screen: modelData
                // Only show on primary screen
                visible: modelData.name === primaryScreenName
            }

            // Workspace display on all screens
            WorkspacesPanel {
                screen: modelData
            }
        }
    }
}
```

### Responsive Layout
```qml
// components/ResponsiveBar.qml
import QtQuick

PanelWindow {
    id: bar

    property int availableWidth: width - 100 // Account for margins

    height: 30
    anchors {
        top: true
        left: true
        right: true
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 15

        // Adaptive layout based on available width
        WorkspacesWidget {
            visible: availableWidth > 600
            anchors.verticalCenter: parent.verticalCenter
        }

        Item { Layout.fillWidth: true }

        BatteryWidget {
            visible: availableWidth > 400
        }

        NetworkWidget {
            visible: availableWidth > 500
        }

        ClockWidget {} // Always visible
    }
}
```

## Data Management Pattern

### Configuration Persistence
```qml
// services/Config.qml
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: config

    // Persistent settings
    PersistentProperties {
        id: settings
        storage: "quickshell-config"

        property string theme: "catppuccin"
        property bool darkMode: true
        property int panelHeight: 30
        property bool showWorkspaces: true
        property bool showBattery: true
        property var widgetOrder: ["workspaces", "window", "battery", "network", "clock"]
    }

    // Computed properties
    readonly property var themeColors: {
        "catppuccin": {
            background: "#1e1e2e",
            surface: "#313244",
            primary: "#89b4fa",
            text: "#cdd6f4"
        },
        "dracula": {
            background: "#282a36",
            surface: "#44475a",
            primary: "#bd93f9",
            text: "#f8f8f2"
        }
    }

    readonly property var currentTheme: themeColors[settings.theme] || themeColors.catppuccin

    // Public API
    function setTheme(themeName) {
        if (themeColors[themeName]) {
            settings.theme = themeName;
            themeChanged();
        }
    }

    function updateWidgetOrder(newOrder) {
        settings.widgetOrder = newOrder;
    }

    signal themeChanged()
}
```

## Performance Optimization Patterns

### Lazy Loading Pattern
```qml
// components/LazyPanel.qml
import QtQuick

Rectangle {
    property bool isVisible: false
    property Component contentComponent

    width: contentLoader.active ? contentLoader.item.width : 0
    height: contentLoader.active ? contentLoader.item.height : 0

    Behavior on width { NumberAnimation { duration: 200 } }
    Behavior on height { NumberAnimation { duration: 200 } }

    Loader {
        id: contentLoader
        active: false
        sourceComponent: contentComponent
        asynchronous: true
    }

    onIsVisibleChanged: {
        contentLoader.active = isVisible;
    }
}
```

### Efficient Updates Pattern
```qml
// components/ThrottledTimer.qml
import QtQuick

Timer {
    property var callback
    property int interval: 500

    running: false
    repeat: false

    function trigger() {
        if (!running) {
            restart();
        }
    }

    onTriggered: {
        if (typeof callback === 'function') {
            callback();
        }
    }
}

// Usage example
ThrottledTimer {
    id: updateTimer
    interval: 1000
    callback: performUpdate
}

function onDataChanged() {
    updateTimer.trigger(); // Throttled update
}

function performUpdate() {
    // Expensive update operation
    updateUI();
}
```

## Error Handling Patterns

### Robust Process Handling
```qml
// services/Network.qml
pragma Singleton
import QtQuick
import Quickshell.Io

Singleton {
    id: network

    property string status: "Unknown"
    property string ssid: ""

    Process {
        id: nmcliProcess
        running: false

        stdout: SplitParser {
            onRead: data => {
                try {
                    const lines = data.trim().split('\n');
                    const activeLine = lines.find(line => line.includes(' connected'));

                    if (activeLine) {
                        const parts = activeLine.split(':');
                        network.ssid = parts[1].trim() || "Unknown";
                        network.status = "Connected";
                    } else {
                        network.status = "Disconnected";
                        network.ssid = "";
                    }
                } catch (error) {
                    console.error("Error parsing network data:", error);
                    network.status = "Error";
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.error("Network command failed with code:", exitCode);
                network.status = "Error";
            }

            // Retry after delay
            retryTimer.restart();
        }
    }

    Timer {
        id: retryTimer
        interval: 10000 // 10 seconds
        onTriggered: updateNetworkStatus()
    }

    function updateNetworkStatus() {
        if (!nmcliProcess.running) {
            nmcliProcess.command = ["nmcli", "-t", "dev", "wifi"];
            nmcliProcess.running = true;
        }
    }

    Component.onCompleted: updateNetworkStatus()
}
```

## Animation and Transition Patterns

### Smooth State Transitions
```qml
// components/AnimatedWidget.qml
import QtQuick

Rectangle {
    id: widget

    property bool isActive: false
    property color activeColor: "#89b4fa"
    property color inactiveColor: "#45475a"

    width: 100
    height: 30
    radius: 5

    color: inactiveColor

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    states: [
        State {
            name: "active"
            when: isActive
            PropertyChanges {
                target: widget;
                color: activeColor;
                width: 120
            }
        },
        State {
            name: "inactive"
            when: !isActive
            PropertyChanges {
                target: widget;
                color: inactiveColor;
                width: 100
            }
        }
    ]

    transitions: [
        Transition {
            from: "inactive"; to: "active"
            SequentialAnimation {
                NumberAnimation { property: "width"; duration: 150 }
                ColorAnimation { duration: 200 }
            }
        },
        Transition {
            from: "active"; to: "inactive"
            SequentialAnimation {
                ColorAnimation { duration: 150 }
                NumberAnimation { property: "width"; duration: 200 }
            }
        }
    ]
}
```

## Testing and Debugging Patterns

### Debug Component
```qml
// components/DebugOverlay.qml
import QtQuick

Rectangle {
    id: debugOverlay

    visible: Qt.application.arguments.includes("--debug")
    color: "#80000000"
    z: 1000

    Text {
        id: debugText
        color: "#00ff00"
        font.family: "monospace"
        font.pixelSize: 12
        anchors.margins: 10
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            debugText.text = new Date().toLocaleString() + "\n" +
                           "Memory: " + Math.round(Profiler.memoryUsage / 1024 / 1024) + "MB\n" +
                           "Active windows: " + WindowManager.activeWindows.length;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            debugOverlay.visible = false;
        }
    }
}
```

### Performance Monitor
```qml
// services/PerformanceMonitor.qml
pragma Singleton
import QtQuick

Singleton {
    id: monitor

    property int frameCount: 0
    property real fps: 0
    property int memoryUsage: 0

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            monitor.fps = frameCount;
            frameCount = 0;
            memoryUsage = getMemoryUsage();
        }
    }

    function onFramePainted() {
        frameCount++;
    }

    function getMemoryUsage() {
        // Platform-specific memory usage calculation
        return 0; // Implementation depends on platform
    }
}
```

## Best Practices Summary

1. **Service Pattern**: Use singletons for system integration and reusable functionality
2. **Process Management**: Declare processes once, reuse via running property
3. **Error Handling**: Always handle process failures and service unavailability
4. **Performance**: Use timers and lazy loading to optimize resource usage
5. **State Management**: Implement proper state machines for UI transitions
6. **Multi-Screen**: Design responsive layouts that work across different screen sizes
7. **Configuration**: Use PersistentProperties for settings that should survive reloads
8. **Testing**: Include debug overlays and performance monitoring for development
9. **Modularity**: Break down complex UI into reusable components
10. **Documentation**: Comment complex logic and provide clear APIs for components