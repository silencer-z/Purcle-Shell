# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AI Guidance

- Think before acting; verify tool results and plan next steps before proceeding.  
- When multiple independent operations are needed, run them in parallel.  
- Do exactly what is asked — nothing more, nothing less.  
- Edit existing files instead of creating new ones; only create new files if explicitly required.  
- Update relevant markdown or memory files if you modify project context.  
- Verify solutions before finishing.

## Project Overview

This is a Quickshell configuration for Hyprland that creates a functional and aesthetic desktop environment. It provides a top bar, launcher, clipboard, and various system utilities using QML and Quickshell framework.

## Architecture

The codebase follows a three-tier modular architecture:

- **Services (Data & Logic)** – `services/`
  - Singleton QMLs integrating system info (Audio, Network, Battery, etc.)
  - Expose reactive state and async methods.

- **Components (Reusable UI)** – `components/`
  - Base UI elements with theme styling (StyledRect, StyledText, etc.)

- **Modules (UI Apps)** – `modules/`
  - User-facing panels and bars (bar/, panels/, osd/)
  - Combine services and components to form user interactions.


## Technology Stack

- **QML (Qt Modeling Language)** - Primary language for all UI components
- **Quickshell Framework** - QML-based framework for building desktop shells
- **Qt/QtQuick 6.x** - UI rendering and controls
- **Wayland** - Display server protocol
- **Matugen** - Dynamic theming system for wallpaper-based colors and system app theming
- **PipeWire** - Low-level audio and video integration (via Quickshell.Pipewire)

## Development Commands

### Running Quickshell

Since this is a Quickshell-based project without traditional build configuration files, development typically involves:

```bash
# Run the shell (requires Quickshell to be installed)
quickshell -p shell.qml
# Or use the shorthand
qs -p .
# Code formatting and linting
qmlformat -i **/*.qml    # Format all QML files in place
qmllint **/*.qml         # Lint all QML files for syntax errors
```

## Key Patterns

### Service Layer Design Principles

#### **Service Interface Standards**

All services should follow this standardized interface pattern:

```qml
pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // === Reactive Properties ===
    readonly property bool isConnected: false
    readonly property string status: "disconnected"
    property bool autoConnect: true

    // === Signals ===
    signal stateChanged(oldState: string, newState: string)
    signal errorOccurred(message: string)
    

    // === Process ===
    Process {
        id: myProcess
        running: false
        command: ["sh", "-c", "system-command"]

        stdout: SplitParser {
            onRead: data => { /* parse output */ }
        }

        onExited: (exitCode, exitStatus) => {
            // Handle process completion
        }
    }

    // === Methods ===
    function executeCommand() {
        myProcess.running = true;
    }

    function executeCustomCommand(cmd) {
        myProcess.command = ["sh", "-c", cmd];
        myProcess.running = true;
    }
}
```

#### **Service Responsibilities**

1. **Data Management**: Provide reactive properties for system state
2. **Configuration**: Manage user settings and preferences
3. **Operations**: Execute system commands with proper error handling
4. **Event Emission**: Notify UI components of state changes
5. **Validation**: Ensure data integrity and handle edge cases

#### **Process Usage Guidelines**

1. **Declaration**: Declare Process once with `running: false`
2. **Startup**: Set `running: true` or change `command` then set `running: true`
3. **Reuse**: Use functions to modify `command` and restart via `running` property
4. **Output**: Handle via `stdout`/`stderr` with appropriate parsers
5. **Completion**: Handle via `onExited` signal
6. **Cleanup**: Use `signal()` for forced termination if needed
7. **Event-Driven**: Use system events instead of polling when possible
8. **Error Handling**: Always handle process exit codes and errors
9. **Resource Management**: Reuse Process instances, avoid frequent creation
10. **Async Operations**: Use Promise pattern for complex operations

### Panel Management

#### **PanelWrapper State Machine**

Panels use a state machine pattern managed by `PanelWrapper.qml`:

```qml
// State constants
readonly property int stateClosed: 0
readonly property int stateLoading: 1
readonly property int stateOpen: 2
readonly property int stateClosing: 3
property int panelState: stateClosed

// Panel interface pattern
required property var panelWrapper
function close() { /* custom close logic */ }
function init() { /* custom initialization */ }
```

**State Flow**: `Closed → Loading → Open → Closing → Closed`

**Key Features**:
- Content switching without closing (toggle behavior)
- Asynchronous loading with Loader component
- Height animations with cubic easing (250ms)
- Focus grab for keyboard interaction
- Rounded bottom panel with drop shadow

## Component Library

### Styled Components

The `components/` directory provides reusable, theme-aware UI building blocks:

| Component | Purpose |
|-----------|---------|
| `StyledRect` | Base container with theme colors and styling |
| `StyledText` | Unified text styling |
| `StyledIcon` | Icon rendering with theme support |
| `StyledButton` | Clickable button with command execution |
| `StyledSlider` | Value slider with size presets (XS-XL) and tooltips |
| `StyledTextInput` | Text input field |
| `StyledPopup` | Popup container |
| `BarWidget` | Base class for top bar widgets |
| `PanelWidget` | Base class for dashboard panels |
| `RoundCorner` | Decorative corner element |
| `IconText` | Icon + text layout |

### Component Patterns

```qml
// StyledButton - command execution
StyledButton {
    text: "Run Command"
    icon: "run"
    command: "sh -c echo hello"
}

// StyledSlider - with size preset
StyledSlider {
    sizePreset: StyledSlider.SizeM
    from: 0
    to: 100
    value: 50
}
```

## Popup System

The `modules/popups/` directory provides transient overlay notifications:

### NotificationPopup

Positioned in the top-right corner with slide-in animations:

```qml
PanelWindow {
    // Positioning
    screen: QtQuick.screens[0]
    x: screen.width - width - 20
    y: 20

    // Animation
    property bool isOpen: true
}
```

**Features**:
- Slide-in from right (400ms), slide-out (300ms)
- Rich content support (icons, images, actions)
- Priority-based queue management via `NoticeService`
- Interactive dismiss actions

### Popup Integration Pattern

Popups integrate with services via singleton binding:

```qml
import qs.services

NoticeService {
    id: notifications
}

NotificationPopup {
    // Bind to service data
    model: notifications.queue
}
```

## File Organization

```md
├── shell.qml                 # Main entry point with ShellRoot and GlobalShortcuts
├── docs/                     # Quickshell API documentation
├── modules/
│   ├── bar/                 # Top bar components and widgets
│   ├── panels/              # User-facing panels (Dashboard, Launcher, Clipboard)
│   │   └── widgets/         # Dashboard widget components
│   ├── popups/              # Transient overlay notifications
│   └── osd/                 # On-screen displays (volume, brightness)
├── services/                # System integration services (root level)
├── components/              # Reusable UI components
└── themes/                  # Visual theme definitions
```

Follow the structure and patterns above. Do not introduce new directories, files, or architectural changes unless explicitly requested.
