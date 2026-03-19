# Quickshell.IO API Documentation

This document covers input/output operations and system integration in Quickshell.

## Process Management

### Process
The main type for executing external commands and scripts.

#### Key Properties
- `command`: Array of strings representing command and arguments
- `running`: Boolean to start/stop process execution
- `workingDirectory`: Process execution directory
- `environment`: Environment variables for process

#### Signals
- `onExited(exitCode, exitStatus)`: Process completion handler
- `stdout`: Standard output stream
- `stderr`: Standard error stream

#### Usage Pattern
```qml
Process {
    id: myProcess
    running: false
    command: ["sh", "-c", "system-command"]

    stdout: SplitParser {
        onRead: data => {
            // Parse output data
        }
    }

    onExited: (exitCode, exitStatus) => {
        // Handle process completion
        if (exitCode !== 0) {
            console.error("Process failed with code:", exitCode);
        }
    }
}

// Usage functions:
function executeCommand() {
    myProcess.running = true;
}

function executeCustomCommand(cmd) {
    myProcess.command = ["sh", "-c", cmd];
    myProcess.running = true;
}
```

### Process Usage Guidelines
1. **Declaration**: Declare Process once with `running: false`
2. **Startup**: Set `running: true` or modify command then start
3. **Reuse**: Use functions to change command and restart via `running` property
4. **Output**: Handle via `stdout`/`stderr` with appropriate parsers
5. **Completion**: Handle via `onExited` signal
6. **Cleanup**: Use `signal()` for forced termination if needed

### SplitParser
Splits process output into manageable chunks or lines.

#### Key Properties
- `delimiter`: String or regex to split output by

#### Usage Example
```qml
Process {
    // ... process configuration

    stdout: SplitParser {
        delimiter: "\n"
        onRead: line => {
            console.log("Received line:", line);
            processLine(line);
        }
    }
}
```

### StdioCollector
Collects and manages standard input/output for interactive processes.

#### Use Cases
- Interactive shells
- Programs requiring user input
- Real-time command/response systems

## File Operations

### FileView
Provides file system browsing and directory listing capabilities.

#### Key Properties
- `path`: Directory path to view
- `filter`: File filter patterns
- `showHidden`: Include hidden files

#### Usage Example
```qml
FileView {
    id: fileView
    path: "/home/user/Documents"
    filter: ["*.qml", "*.js"]

    onPathChanged: {
        console.log("Viewing directory:", path);
    }
}
```

### FileViewAdapter
Adapter that provides a model interface for FileView data.

#### Use Cases
- Integration with ListView/GridView
- Data binding in QML
- Custom file browsers

### FileViewError
Error handling for file operations.

#### Key Properties
- `error`: Error type/code
- `message`: Human-readable error description
- `path`: Path that caused the error

## Network and IPC

### Socket
Network socket communication supporting TCP/UDP protocols.

#### Key Properties
- `host`: Target hostname or IP
- `port`: Target port number
- `connected`: Connection status
- `sslEnabled`: Enable SSL/TLS

#### Usage Example
```qml
Socket {
    id: tcpSocket
    host: "example.com"
    port: 8080

    onConnected: {
        console.log("Connected to server");
        send("Hello Server");
    }

    onDataReceived: data => {
        console.log("Received:", data);
    }

    onError: error => {
        console.error("Socket error:", error);
    }
}
```

### SocketServer
Server socket for accepting incoming connections.

#### Key Properties
- `listening`: Server active status
- `port`: Listening port
- `maxConnections`: Maximum concurrent connections

#### Use Cases
- Local services
- IPC servers
- Network utilities

### IpcHandler
Inter-process communication handler for local process communication.

#### Use Cases
- Communication between Quickshell instances
- Integration with external applications
- Local service coordination

## Data Streams

### DataStream
Generic interface for stream-based data operations.

#### Use Cases
- File streams
- Network streams
- Custom data sources

### DataStreamParser
Base parser for processing stream data in real-time.

#### Use Cases
- Log file parsing
- Network protocol parsing
- Real-time data processing

## JSON Processing

### JsonAdapter
Provides a model interface for JSON data structures.

#### Key Properties
- `source`: JSON data source
- `query`: JSONPath or similar query syntax

#### Usage Example
```qml
JsonAdapter {
    id: jsonAdapter
    source: '{"users": [{"name": "Alice"}, {"name": "Bob"}]}'
    query: "$.users"
}
```

### JsonObject
Represents JSON objects with dynamic property access.

#### Use Cases
- API response handling
- Configuration files
- Dynamic data structures

## Practical Examples

### Battery Monitor
```qml
Process {
    id: batteryProcess
    running: false
    command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity"]

    stdout: SplitParser {
        onRead: data => {
            batteryLevel = parseInt(data.trim());
            updateBatteryIcon();
        }
    }

    onExited: (exitCode, exitStatus) => {
        if (exitCode === 0) {
            // Restart after delay
            restartTimer.restart();
        }
    }
}

Timer {
    id: restartTimer
    interval: 30000 // 30 seconds
    onTriggered: batteryProcess.running = true
}
```

### Network Status Checker
```qml
Process {
    id: pingProcess
    running: false
    command: ["ping", "-c", "1", "8.8.8.8"]

    onExited: (exitCode, exitStatus) => {
        isOnline = (exitCode === 0);
    }
}

// Function to check connectivity
function checkConnectivity() {
    pingProcess.running = true;
}
```

### File Watcher
```qml
FileView {
    id: configWatcher
    path: "/home/user/.config/myapp/"

    onModelChanged: {
        console.log("Configuration files changed");
        reloadConfiguration();
    }
}
```

## Best Practices

1. **Resource Management**: Always set `running: false` initially and control execution explicitly
2. **Error Handling**: Implement proper `onExited` handlers for all processes
3. **Performance**: Use `SplitParser` for line-by-line processing of large outputs
4. **Security**: Validate external inputs before using in command construction
5. **Cleanup**: Implement proper cleanup in component destruction handlers
6. **Threading**: Remember that process execution is asynchronous - handle responses appropriately