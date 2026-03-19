# Quickshell Window Manager Integration API Documentation

This document covers window manager integration modules in Quickshell.

## Hyprland Integration

Integration with Hyprland window manager for advanced desktop functionality.

### Hyprland
Main Hyprland interface providing IPC communication.

#### Key Properties
- `connected`: Connection status to Hyprland
- `version`: Hyprland version information

#### Usage Example
```qml
import Quickshell.Hyprland

Hyprland {
    id: hyprland

    onConnectedChanged: {
        console.log("Hyprland connection:", connected);
    }
}
```

### GlobalShortcut
System-wide hotkey registration.

#### Key Properties
- `key`: Key combination (e.g., "space", "return")
- `modifiers`: Modifier keys (Qt.MetaModifier, Qt.ControlModifier)
- `name`: Unique identifier for the shortcut

#### Usage Example
```qml
GlobalShortcut {
    name: "launcher"
    key: "space"
    modifiers: Qt.MetaModifier

    onTriggered: {
        launcherWindow.visible = true;
    }
}

GlobalShortcut {
    name: "clipboard"
    key: "v"
    modifiers: Qt.MetaModifier | Qt.ShiftModifier

    onTriggered: {
        clipboardPanel.open();
    }
}
```

### HyprlandWindow
Represents a Hyprland window.

#### Key Properties
- `address`: Unique window identifier
- `title`: Window title
- `class`: Window class/application name
- `workspace`: Containing workspace
- `monitor`: Containing monitor
- `floating`: Whether window is floating
- `fullscreen`: Whether window is fullscreen
- `focused`: Whether window has focus

#### Usage Example
```qml
Hyprland {
    id: hyprland

    property var activeWindow: null

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            activeWindow = hyprland.getFocusedWindow();
            if (activeWindow) {
                windowTitle = activeWindow.title;
                windowClass = activeWindow.class;
            }
        }
    }
}
```

### HyprlandWorkspace
Represents a Hyprland workspace.

#### Key Properties
- `id`: Workspace number
- `name`: Workspace name
- `monitor`: Containing monitor
- `windows`: List of windows in workspace
- `active`: Whether workspace is active

### HyprlandMonitor
Represents a Hyprland monitor/output.

#### Key Properties
- `id`: Monitor identifier
- `name`: Monitor name
- `geometry`: Monitor geometry (x, y, width, height)
- `activeWorkspace`: Currently active workspace
- `scale`: Display scale factor

### HyprlandToplevel
Base type for Hyprland windows.

#### Key Properties
- `focus`: Focus state
- `geometry`: Window geometry
- `mapped`: Whether window is mapped

### HyprlandFocusGrab
Input focus grabbing for special input handling.

#### Use Cases
- Custom input methods
- Overlay keyboards
- Special input modes

### HyprlandEvent
Event handling for Hyprland IPC events.

#### Common Events
- `workspace`: Workspace changes
- `activewindow`: Active window changes
- `monitor`: Monitor changes
- `fullscreen`: Fullscreen state changes

#### Usage Example
```qml
Hyprland {
    id: hyprland

    onEvent: (event) => {
        switch (event.type) {
            case "workspace":
                console.log("Workspace changed to:", event.data);
                break;
            case "activewindow":
                console.log("Active window:", event.data);
                break;
        }
    }
}
```

## I3 Integration

Integration with I3 window manager.

### I3
Main I3 interface.

#### Key Properties
- `connected`: Connection status
- `version`: I3 version

### I3Workspace
I3 workspace representation.

#### Key Properties
- `num`: Workspace number
- `name`: Workspace name
- `visible`: Whether workspace is visible
- `focused`: Whether workspace is focused
- `urgent`: Whether workspace has urgent windows

### I3Monitor
I3 monitor/output.

#### Key Properties
- `name`: Monitor name
- `geometry`: Monitor geometry
- `activeWorkspace`: Currently active workspace

### I3Event
I3 event handling.

#### Common Events
- `workspace`: Workspace changes
- `output`: Output changes
- `mode`: Mode changes

## Wayland Integration

Low-level Wayland protocol integration.

### WlrLayer
Wayland layer shell surface.

#### Key Properties
- `layer`: Layer level (background, bottom, top, overlay)
- `anchor`: Edge anchors
- `exclusiveZone`: Exclusive area for panels
- `margin`: Margins from screen edges

#### Layer Levels
- `Background`: Behind all windows
- `Bottom`: Above background, below windows
- `Top`: Above windows, below overlays
- `Overlay`: Above everything

#### Usage Example
```qml
import Quickshell.Wayland

WlrLayer {
    anchors {
        top: true
        left: true
        right: true
    }
    layer: WlrLayer.Top
    exclusiveZone: 30 // Reserve 30px for panels

    // Panel content here
}
```

### WlrLayershell
Layer shell implementation for creating panels and overlays.

#### Key Properties
- `surface`: Layer surface
- `namespace`: Unique identifier
- `layer`: Layer level
- `anchor`: Anchoring configuration

### Toplevel
Wayland toplevel window (application windows).

#### Key Properties
- `title`: Window title
- `appId`: Application identifier
- `state`: Window state (maximized, fullscreen, etc.)
- `active`: Whether window is active

### ToplevelManager
Manages all toplevel windows.

#### Use Cases
- Window lists
- Alt-tab functionality
- Window switching

### ScreencopyView
Screen capture interface for screenshots and screen sharing.

#### Key Properties
- `source`: Capture source (monitor, window)
- `texture`: Captured texture

#### Usage Example
```qml
ScreencopyView {
    id: screenshotView
    source: ScreenManager.primaryScreen

    onTextureChanged: {
        if (texture) {
            saveScreenshot(texture);
        }
    }

    function capture() {
        capture();
    }
}
```

### IdleMonitor
System idle time monitoring.

#### Key Properties
- `idle`: Whether system is idle
- `timeout`: Idle timeout in milliseconds

#### Usage Example
```qml
IdleMonitor {
    id: idleMonitor
    timeout: 300000 // 5 minutes

    onIdleChanged: {
        if (idle) {
            console.log("System is idle");
            enableScreensaver();
        } else {
            console.log("System is active");
            disableScreensaver();
        }
    }
}
```

### IdleInhibitor
Prevents system from going to sleep or screensaver.

#### Key Properties
- `active`: Whether inhibition is active
- `application`: Application name

### WlSessionLock
Session lock interface for lock screens.

#### Key Properties
- `locked`: Whether session is locked
- `surface`: Lock surface

### WlSessionLockSurface
Display surface for session lock.

#### Use Cases
- Custom lock screens
- Authentication UI
- Security overlays

### WlrKeyboardFocus
Keyboard focus tracking.

#### Key Properties
- `surface`: Focused surface
- `focused`: Focus state

## Practical Examples

### Multi-Monitor Workspace Display
```qml
Variants {
    model: hyprland.monitors

    Scope {
        required property HyprlandMonitor modelData

        Repeater {
            model: modelData.workspaces

            Rectangle {
                property var workspace: modelData

                width: 40
                height: 30
                color: workspace.active ? "#89b4fa" : "#45475a"
                border.color: workspace.visible ? "#f38ba8" : "transparent"

                Text {
                    text: workspace.id
                    anchors.centerIn: parent
                    color: "#cdd6f4"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        hyprland.switchWorkspace(workspace.id);
                    }
                }
            }
        }
    }
}
```

### Active Window Display
```qml
Text {
    id: windowTitle

    property var activeWindow: null

    text: activeWindow ? activeWindow.title : "No active window"
    color: "#cdd6f4"

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            activeWindow = hyprland.getFocusedWindow();
        }
    }
}
```

### Layer Shell Panel
```qml
WlrLayershell {
    width: Screen.width
    height: 30
    layer: WlrLayer.Top

    anchors {
        top: true
        left: true
        right: true
    }

    exclusiveZone: 30

    // Panel content
    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        // Left side components
        // Center components
        // Right side components
    }
}
```

### Global Shortcuts
```qml
Column {
    GlobalShortcut {
        name: "launcher"
        key: "space"
        modifiers: Qt.MetaModifier
        onTriggered: launcher.show()
    }

    GlobalShortcut {
        name: "terminal"
        key: "return"
        modifiers: Qt.MetaModifier
        onTriggered: terminal.launch()
    }

    GlobalShortcut {
        name: "browser"
        key: "b"
        modifiers: Qt.MetaModifier
        onTriggered: browser.launch()
    }
}
```

## Best Practices

1. **Connection Management**: Always check connection status before using WM APIs
2. **Event Handling**: Use appropriate event signals for reactive updates
3. **Resource Cleanup**: Clean up resources when components are destroyed
4. **Performance**: Use timers for polling instead of frequent property checks
5. **Error Handling**: Handle WM disconnection gracefully
6. **Multi-Monitor**: Test configurations across different monitor setups