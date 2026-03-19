# Quickshell Core API Documentation

This document covers the fundamental Quickshell types for building desktop shell environments.

## Quickshell Core Types

### Window Management

#### PanelWindow
- **Purpose**: Decorationless window attached to screen edges by anchors
- **Use Cases**: Creating panels, bars, and docks
- **Key Properties**:
  - `anchors`: Position relative to screen edges
  - `exclusionMode`: How window affects other applications
  - `margins`: Spacing from screen edges
- **Example**: Top bar, bottom panel, side dock

#### PopupWindow
- **Purpose**: Popup window for temporary UI elements
- **Use Cases**: Menus, dropdowns, notifications
- **Key Properties**:
  - `visible`: Show/hide popup
  - `parent`: Anchor point for positioning
  - `anchors`: Positioning relative to parent
- **Features**: Automatic screen bound adjustment

#### FloatingWindow
- **Purpose**: Standard toplevel window with system decorations
- **Use Cases**: Application windows, settings dialogs
- **Key Properties**:
  - `title`: Window title
  - `flags`: Window behavior flags
  - `visibility`: Show/hide window

#### QsWindow
- **Purpose**: Base class for all Quickshell windows
- **Use Cases**: Foundation for custom window types
- **Key Properties**:
  - `screen`: Target screen
  - `visibility`: Window visibility
  - `geometry`: Window position and size

### Component Management

#### ShellRoot
- **Purpose**: Root configuration element for main entry point
- **Use Cases**: Main configuration file, global settings
- **Key Properties**:
  - `screens`: Available screens
  - `settings`: Global configuration

#### Scope
- **Purpose**: Manages component reload and lifecycle
- **Use Cases**: Organizing component hierarchies, managing reloads
- **Features**: Ordered reload propagation to children

#### Variants
- **Purpose**: Creates component instances based on a model
- **Use Cases**: Multi-screen support, dynamic UI generation
- **Key Properties**:
  - `model`: Data model for instance creation
  - `delegate`: Component to instantiate
- **Example**: Creating panels for each screen

#### Singleton
- **Purpose**: Root component for single-instance services
- **Use Cases**: System services, global state management
- **Features**: Persists across configuration reloads

### Layout and Geometry

#### Region
- **Purpose**: Composable mask for defining interactive areas
- **Use Cases**: Click zones, drag areas, visual masking
- **Key Properties**:
  - `shape`: Geometric form of region
  - `mask`: Interaction behavior

#### RegionShape
- **Purpose**: Defines geometric shapes for regions
- **Supported Shapes**: Rectangles, circles, custom paths
- **Use Cases**: Complex hit testing, visual effects

#### Edges
- **Purpose**: Edge positioning flags (Top, Left, Right, Bottom)
- **Use Cases**: Anchoring components, layout constraints
- **Features**: Support for edge combinations

#### Intersection
- **Purpose**: Defines how regions interact
- **Use Cases**: Hit testing, collision detection
- **Strategies**: Overlap, containment, custom logic

### Data and Models

#### ObjectModel
- **Purpose**: Model interface for object collections
- **Use Cases**: Displaying lists of objects, data binding
- **Key Properties**:
  - `object`: Source object
  - `count`: Number of items

#### ObjectRepeater
- **Purpose**: Creates instances from data model (like for loop)
- **Use Cases**: Dynamic component generation, lists
- **Key Properties**:
  - `model`: Data source
  - `delegate`: Component template

#### ScriptModel
- **Purpose**: Dynamic model from JavaScript expressions
- **Use Cases**: Computed data, filtered lists
- **Key Properties**:
  - `script`: JavaScript expression
  - `evaluation`: When to recompute

#### LazyLoader
- **Purpose**: Asynchronous component loading
- **Use Cases**: Performance optimization, on-demand loading
- **Key Properties**:
  - `source`: Component source
  - `status`: Loading state

### State and Properties

#### PersistentProperties
- **Purpose**: Properties that persist across config reloads
- **Use Cases**: User preferences, UI state, settings
- **Key Properties**:
  - `storage`: Storage backend
  - `values`: Stored properties

#### Reloadable
- **Purpose**: Base class for reloadable components
- **Use Cases**: Hot reloading, configuration updates
- **Key Properties**:
  - `reloadable`: Enable/disable reloading
  - `onReload`: Reload handler

#### Retainable
- **Purpose**: Delayed destruction for objects
- **Use Cases**: Animation cleanup, resource management
- **Key Properties**:
  - `retain`: Prevent destruction
  - `release`: Allow destruction

### Utilities

#### SystemClock
- **Purpose**: System time and date access
- **Use Cases**: Clocks, timers, date display
- **Key Properties**:
  - `time`: Current time
  - `date`: Current date

#### ElapsedTimer
- **Purpose**: Time measurement between events
- **Use Cases**: Performance monitoring, animations
- **Key Properties**:
  - `elapsed`: Time elapsed
  - `running`: Timer state

#### EasingCurve
- **Purpose**: Animation timing functions
- **Use Cases**: Smooth animations, transitions
- **Key Properties**:
  - `type`: Curve type (linear, ease-in/out, etc.)
  - `period`: Animation period
  - `amplitude`: Animation amplitude

#### TransformWatcher
- **Purpose**: Monitors geometry changes between objects
- **Use Cases**: Responsive layouts, dynamic positioning
- **Key Properties**:
  - `target`: Object to watch
  - `watched`: Reference object

## Common Patterns

### Multi-Screen Setup
```qml
Variants {
    model: Quickshell.screens

    Scope {
        required property ShellScreen modelData

        PanelWindow {
            screen: modelData
            // Panel configuration
        }
    }
}
```

### Persistent State
```qml
PersistentProperties {
    id: settings
    property bool darkMode: false
    property int panelHeight: 30
}
```

### Component Lifecycle
```qml
Scope {
    Reloadable {
        // Component that supports hot reload
        onReload: {
            // Cleanup and reinitialize
        }
    }
}
```