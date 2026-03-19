import QtQuick
pragma Singleton

QtObject {
    // Background
    // Current line
    // Selection
    // Comment
    // Dark foreground
    // Foreground
    // Light foreground
    // Light background
    // Red
    // Orange
    // Yellow
    // Green
    // Cyan
    // Blue
    // Magenta
    // Orange
    // Light background
    // Lighter background
    // Selection
    // Comment
    // Dark foreground
    // Dark text
    // Darker text
    // Darkest
    // Red (adjusted for light)
    // Orange
    // Yellow
    // Green
    // Cyan
    // Blue
    // Magenta
    // Orange

    readonly property var dark: ({
        "name": "Dracula",
        "type": "dark",
        "base00": "#282a36",
        "base01": "#44475a",
        "base02": "#565761",
        "base03": "#6272a4",
        "base04": "#6272a4",
        "base05": "#f8f8f2",
        "base06": "#f8f8f2",
        "base07": "#ffffff",
        "base08": "#ff5555",
        "base09": "#ffb86c",
        "base0A": "#f1fa8c",
        "base0B": "#50fa7b",
        "base0C": "#8be9fd",
        "base0D": "#bd93f9",
        "base0E": "#ff79c6",
        "base0F": "#ffb86c"
    })
    readonly property var light: ({
        "name": "Dracula Light",
        "type": "light",
        "base00": "#f8f8f2",
        "base01": "#ffffff",
        "base02": "#e5e5e5",
        "base03": "#bfbfbf",
        "base04": "#6272a4",
        "base05": "#282a36",
        "base06": "#21222c",
        "base07": "#191a21",
        "base08": "#e74c3c",
        "base09": "#f39c12",
        "base0A": "#f1c40f",
        "base0B": "#27ae60",
        "base0C": "#17a2b8",
        "base0D": "#6c7ce0",
        "base0E": "#e91e63",
        "base0F": "#f39c12"
    })
}
