# Quickshell Services API Documentation

This document covers various service modules in Quickshell for system integration.

## SystemTray Service

System tray integration for managing tray icons and applications.

### SystemTray
Main tray management interface.

#### Key Properties
- `items`: List of tray items
- `status`: Overall tray status

#### Usage Example
```qml
import Quickshell.Services.SystemTray

SystemTray {
    onItemsChanged: {
        console.log("Tray items updated:", items.length);
    }
}
```

### SystemTrayItem
Represents an individual tray application.

#### Key Properties
- `title`: Application title
- `icon`: Tray icon
- `menu`: Context menu (if available)
- `tooltip`: Hover tooltip text

### Status Enum
Tray item status values:
- `Active`: Application is active and running
- `Passive`: Application is running but inactive
- `NeedsAttention`: Application requires user attention

### Category Enum
Tray item categories:
- `ApplicationStatus`: Regular application
- `Communications`: Communication app (chat, email)
- `SystemServices`: System service or daemon
- `Hardware`: Hardware-related application

## UPower Service

Power management and battery monitoring.

### UPower
Main power management interface.

#### Key Properties
- `devices`: List of power devices
- `onBattery`: True if running on battery power

#### Usage Example
```qml
import Quickshell.Services.UPower

UPower {
    id: upower
    onOnBatteryChanged: {
        console.log("Power source changed:", onBattery ? "Battery" : "AC");
    }

    onDevicesChanged: {
        updateBatteryInfo();
    }
}
```

### UPowerDevice
Represents a power device (battery, AC adapter, etc.).

#### Key Properties
- `type`: Device type (battery, AC, UPS, etc.)
- `state`: Current charging state
- `percentage`: Battery level (0-100)
- `timeToEmpty`: Time until battery empty (seconds)
- `timeToFull`: Time until fully charged (seconds)

### UPowerDeviceState Enum
- `Unknown`: Device state unknown
- `Charging`: Device is charging
- `Discharging`: Device is discharging
- `Empty`: Device is empty
- `Full`: Device is fully charged

### UPowerDeviceType Enum
- `Unknown`: Unknown device type
- `LinePower`: AC power adapter
- `Battery`: Rechargeable battery
- `Ups`: Uninterruptible Power Supply
- `Monitor`: Display device

### PowerProfile
Power profile settings for performance/power management.

#### Key Properties
- `name`: Profile name
- `active`: Whether profile is active

## Mpris Service

Media player integration via MPRIS protocol.

### Mpris
Main MPRIS interface for managing media players.

#### Key Properties
- `players`: List of available media players

#### Usage Example
```qml
import Quickshell.Services.Mpris

Mpris {
    id: mpris
    onPlayersChanged: {
        if (players.length > 0) {
            currentTrack = players[0].metadata["xesam:title"];
            isPlaying = players[0].playbackState === MprisPlaybackState.Playing;
        }
    }
}
```

### MprisPlayer
Individual media player instance.

#### Key Properties
- `playbackState`: Current playback state
- `metadata`: Track metadata dictionary
- `loopState`: Loop/repeat mode
- `shuffle`: Shuffle mode
- `volume`: Volume level (0.0-1.0)

#### Methods
- `play()`: Start playback
- `pause()`: Pause playback
- `stop()`: Stop playback
- `next()`: Next track
- `previous()`: Previous track

### MprisPlaybackState Enum
- `Stopped`: Playback stopped
- `Playing`: Currently playing
- `Paused`: Playback paused

### MprisLoopState Enum
- `None`: No looping
- `Track`: Repeat current track
- `Playlist`: Repeat entire playlist

## Notifications Service

System notification handling.

### NotificationServer
Main notification daemon interface.

#### Key Properties
- `notifications`: List of active notifications

#### Usage Example
```qml
import Quickshell.Services.Notifications

NotificationServer {
    id: notificationServer
    onNotificationAdded: notification => {
        console.log("New notification:", notification.summary);
        showNotification(notification);
    }
}
```

### Notification
Individual system notification.

#### Key Properties
- `appName`: Application name
- `summary`: Notification title
- `body`: Notification content
- `urgency`: Importance level
- `actions`: Available actions
- `timeout`: Display duration
- `icon`: Notification icon

#### Methods
- `close(reason)`: Close notification with reason

### NotificationAction
Action button for notifications.

#### Key Properties
- `id`: Action identifier
- `label`: Display text

### NotificationCloseReason Enum
- `Expired`: Notification timed out
- `Dismissed`: User dismissed
- `Action`: User clicked action
- `API`: Closed via API

### NotificationUrgency Enum
- `Low`: Low importance
- `Normal`: Normal importance
- `Critical`: High importance

## Bluetooth Service

Bluetooth device management.

### Bluetooth
Main Bluetooth interface.

#### Key Properties
- `adapter`: System Bluetooth adapter
- `devices`: List of discovered devices

#### Usage Example
```qml
import Quickshell.Bluetooth

Bluetooth {
    id: bluetooth
    onDevicesChanged: {
        updateDeviceList();
    }
}
```

### BluetoothAdapter
System Bluetooth adapter.

#### Key Properties
- `name`: Adapter name
- `address`: MAC address
- `state`: Current adapter state
- `powered`: Power state
- `discoverable`: Discoverable state

### BluetoothDevice
Individual Bluetooth device.

#### Key Properties
- `name`: Device name
- `address`: MAC address
- `connected`: Connection status
- `paired`: Pairing status
- `rssi`: Signal strength

### BluetoothAdapterState Enum
- `Unknown`: State unknown
- `PoweredOff`: Adapter disabled
- `PoweredOn`: Adapter enabled

### BluetoothDeviceState Enum
- `Unknown`: State unknown
- `Available`: Device available
- `Connected`: Device connected

## Pipewire Service

Audio system integration via PipeWire.

### Pipewire
Main PipeWire audio interface.

#### Key Properties
- `nodes`: List of audio nodes
- `links`: List of audio connections

#### Usage Example
```qml
import Quickshell.Services.Pipewire

Pipewire {
    id: pipewire
    onNodesChanged: {
        updateAudioDevices();
    }
}
```

### PwNode
PipeWire audio node (device or stream).

#### Key Properties
- `id`: Node identifier
- `type`: Node type
- `name`: Node name
- `state`: Current state

### PwNodeAudio
Audio-specific node with volume control.

#### Key Properties
- `volume`: Volume level (0.0-1.0)
- `mute`: Mute state
- `channels`: Audio channels

### PwLink
Connection between audio nodes.

#### Key Properties
- `from`: Source node
- `to`: Destination node
- `state`: Connection state

### PwLinkState Enum
- `Unlinked`: Not connected
- `Linking`: Connecting
- `Linked`: Connected
- `Paused`: Connection paused
- `Error`: Connection error

### PwNodeType Enum
- `Unknown`: Unknown type
- `Source`: Input device (microphone)
- `Sink`: Output device (speakers)
- `Stream`: Application stream

## Practical Examples

### Battery Monitor
```qml
UPower {
    id: upower

    property var batteryDevice: null

    onDevicesChanged: {
        batteryDevice = devices.find(device =>
            device.type === UPowerDeviceType.Battery
        );
    }

    Timer {
        interval: 5000 // 5 seconds
        running: true
        repeat: true
        onTriggered: {
            if (batteryDevice) {
                batteryLevel = batteryDevice.percentage;
                isCharging = batteryDevice.state === UPowerDeviceState.Charging;
            }
        }
    }
}
```

### Media Controller
```qml
Mpris {
    id: mpris

    property var currentPlayer: null

    onPlayersChanged: {
        currentPlayer = players[0] || null;
        updateMediaInfo();
    }

    function playPause() {
        if (currentPlayer) {
            if (currentPlayer.playbackState === MprisPlaybackState.Playing) {
                currentPlayer.pause();
            } else {
                currentPlayer.play();
            }
        }
    }

    function nextTrack() {
        if (currentPlayer) currentPlayer.next();
    }

    function previousTrack() {
        if (currentPlayer) currentPlayer.previous();
    }
}
```

### Notification Handler
```qml
NotificationServer {
    id: notifications

    property var recentNotifications: []

    onNotificationAdded: notification => {
        recentNotifications.unshift(notification);
        if (recentNotifications.length > 5) {
            recentNotifications.pop();
        }

        // Handle critical notifications
        if (notification.urgency === NotificationUrgency.Critical) {
            showCriticalNotification(notification);
        }
    }
}
```

## Best Practices

1. **Service Initialization**: Check service availability before use
2. **Property Monitoring**: Use property change signals for reactive updates
3. **Error Handling**: Handle service unavailability gracefully
4. **Resource Management**: Clean up resources when services become unavailable
5. **Performance**: Use timers for polling instead of frequent property checks