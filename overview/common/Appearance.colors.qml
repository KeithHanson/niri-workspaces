import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool darkmode: true
    property color m3primary: accent
    property color m3onPrimary: background
    property color m3primaryContainer: selection
    property color m3onPrimaryContainer: foreground
    property color m3secondary: foreground
    property color m3onSecondary: background
    property color m3secondaryContainer: lighterBackground
    property color m3onSecondaryContainer: foreground
    property color m3background: background
    property color m3onBackground: foreground
    property color m3surface: background
    property color m3surfaceContainerLow: darkerBackground
    property color m3surfaceContainer: darkBackground
    property color m3surfaceContainerHigh: selection
    property color m3surfaceContainerHighest: lighterBackground
    property color m3onSurface: foreground
    property color m3surfaceVariant: selection
    property color m3onSurfaceVariant: muted
    property color m3inverseSurface: foreground
    property color m3inverseOnSurface: background
    property color m3outline: accent
    property color m3outlineVariant: muted
    property color m3shadow: "#000000"

    property color background: "#02101E"
    property color darkBackground: "#020c17"
    property color darkerBackground: "#01080f"
    property color lighterBackground: "#1b2835"
    property color foreground: "#37D6F9"
    property color accent: "#468aba"
    property color selection: "#1b2835"
    property color muted: "#64696e"

    readonly property string colorsPath: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme/colors.toml"
    readonly property string themeNamePath: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme.name"
    property string lastColorsRaw: ""

    function requestReload() {
        reloadDelay.restart()
    }

    function applyToml(raw) {
        raw = String(raw || "")
        if (raw === lastColorsRaw)
            return
        lastColorsRaw = raw

        const values = ({})
        for (const line of raw.split("\n")) {
            const match = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"(#[0-9A-Fa-f]{6})"/)
            if (match) values[match[1]] = match[2]
        }

        const modeMatch = raw.match(/^\s*mode\s*=\s*"?([A-Za-z]+)"?/m)
        if (modeMatch) darkmode = modeMatch[1] !== "light"
        if (values.background) background = values.background
        if (values.dark_background) darkBackground = values.dark_background
        if (values.darker_background) darkerBackground = values.darker_background
        if (values.lighter_background) lighterBackground = values.lighter_background
        if (values.foreground) foreground = values.foreground
        if (values.accent) accent = values.accent
        if (values.selection) selection = values.selection
        if (values.muted) muted = values.muted
    }

    Process {
        id: loadColors
        command: ["sh", "-lc", "cat \"$HOME/.local/state/omarchy/current/theme/colors.toml\" 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: root.applyToml(text)
        }
    }

    Timer {
        id: reloadDelay
        interval: 250
        repeat: false
        onTriggered: loadColors.running = true
    }

    Timer {
        // Theme changes can replace/rewrite Omarchy's generated theme files in
        // ways that QFileSystemWatcher occasionally misses, especially when
        // switching back to a previous theme. Polling one tiny TOML file keeps
        // the overview reliably synced with the Omarchy shell.
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!loadColors.running) loadColors.running = true
    }

    FileView {
        path: root.colorsPath
        watchChanges: true
        printErrors: false
        onFileChanged: root.requestReload()
    }

    FileView {
        path: root.themeNamePath
        watchChanges: true
        printErrors: false
        onFileChanged: root.requestReload()
    }
}
