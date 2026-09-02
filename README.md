# Niri Workspaces for Omarchy

Niri-inspired workspace UX for Omarchy/Hyprland:

- left-edge vertical workspace dots with a themed angled panel
- top-left hot corner opens a workspace/window overview
- standalone Quickshell overview shaped as vertical workspace rows with horizontal window strips
- optional Hyprland bindings for vertical workspace movement and horizontal window focus

This is packaged as an Omarchy shell plugin. It also ships an optional Hyprland config snippet because Omarchy plugins do not own compositor keybindings directly; Omarchy's convention is plugin IPC plus Hyprland `o.bind(...)` entries.

## Install from a git URL

```bash
omarchy plugin add https://github.com/YOURNAME/niri-workspaces.git --enable
cd ~/.config/omarchy/plugins/niri-workspaces
./install.sh
```

`install.sh` enables the plugin, copies the Hyprland snippet to `~/.config/hypr/niri-workspaces.lua`, adds `require("hypr.niri-workspaces")` to `~/.config/hypr/hyprland.lua` if missing, reloads Hyprland, and restarts the Omarchy shell.

## Local install from this checkout

```bash
./install.sh
```

## Controls installed by the Hyprland snippet

- `SUPER + GRAVE` — toggle overview
- top-left hot corner — open overview
- `SUPER + UP/DOWN` — previous/next workspace, including empty workspaces
- `SUPER + SHIFT + UP/DOWN` — move focused window to previous/next workspace
- `SUPER + mouse wheel` — previous/next workspace
- `SUPER + SHIFT + mouse wheel` — focus left/right window in the horizontal strip
- `SUPER + ALT + F` — toggle full-width window without fullscreen/maximized state

## Plugin IPC

```bash
omarchy-shell shell call niri-workspaces openOverview '{}'
omarchy-shell shell call niri-workspaces toggleOverview '{}'
```

## Files

```text
manifest.json
NiriWorkspaces.qml
overview/                       # vendored standalone Quickshell overview
scripts/niri-workspaces-hot-corner
scripts/hypr-window-full-width
hypr/niri-workspaces.lua
install.sh
```

## Notes

- The overview is standalone Quickshell because current compositor overview plugins tested (`Hyprspace`, `hycov`) did not build against Hyprland 0.56.2.
- The overview color loader follows Omarchy's current theme via `~/.local/state/omarchy/current/theme/colors.toml`.
- This plugin assumes Omarchy's Lua Hyprland config provider.

## Credits

The overview module is based on [`Shanu-Kumawat/quickshell-overview`](https://github.com/Shanu-Kumawat/quickshell-overview), vendored here so the plugin works without a separate AUR package.

Example plugin packaging was checked against [`bjarneo/omarchy-shell-plugins`](https://github.com/bjarneo/omarchy-shell-plugins) and Omarchy's built-in plugin manifest format.

## License

MIT for this packaging/glue. The vendored overview keeps its upstream license terms; verify before publishing if you intend to distribute publicly.
