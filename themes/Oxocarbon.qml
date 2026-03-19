import QtQuick
pragma Singleton

QtObject {
    // OLED-friendly background
    // Surface 1
    // Surface 2
    // Surface 3
    // Text secondary
    // Text primary
    // Text on color
    // Text inverse
    // Red (pink)
    // Magenta
    // Green
    // Purple
    // Cyan
    // Blue
    // Purple (accent)
    // Teal
    // Light background
    // Surface 1
    // Surface 2
    // Surface 3
    // Text secondary
    // Text primary
    // Text on color
    // Text inverse
    // Red
    // Magenta
    // Green
    // Purple
    // Cyan
    // Blue
    // Purple (accent)
    // Teal

    readonly property var dark: ({
        "name": "Oxocarbon Dark",
        "type": "dark",
        "base00": "#161616",
        "base01": "#262626",
        "base02": "#393939",
        "base03": "#525252",
        "base04": "#6f6f6f",
        "base05": "#c6c6c6",
        "base06": "#e0e0e0",
        "base07": "#f4f4f4",
        "base08": "#ff7eb6",
        "base09": "#ee5396",
        "base0A": "#42be65",
        "base0B": "#be95ff",
        "base0C": "#3ddbd9",
        "base0D": "#78a9ff",
        "base0E": "#be95ff",
        "base0F": "#08bdba"
    })
    readonly property var light: ({
        "name": "Oxocarbon Light",
        "type": "light",
        "base00": "#f4f4f4",
        "base01": "#ffffff",
        "base02": "#e0e0e0",
        "base03": "#c6c6c6",
        "base04": "#525252",
        "base05": "#262626",
        "base06": "#161616",
        "base07": "#000000",
        "base08": "#da1e28",
        "base09": "#d12771",
        "base0A": "#198038",
        "base0B": "#8a3ffc",
        "base0C": "#007d79",
        "base0D": "#0f62fe",
        "base0E": "#8a3ffc",
        "base0F": "#005d5d"
    })
}
