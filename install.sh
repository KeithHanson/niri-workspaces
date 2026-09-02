#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
plugin_id="niri-workspaces"
plugin_dir="$HOME/.config/omarchy/plugins/$plugin_id"
hypr_target="$HOME/.config/hypr/niri-workspaces.lua"
hyprland_lua="$HOME/.config/hypr/hyprland.lua"

mkdir -p "$HOME/.config/omarchy/plugins" "$HOME/.config/hypr"
rm -rf "$plugin_dir"
cp -a "$repo_dir" "$plugin_dir"
rm -rf "$plugin_dir/.git"
chmod +x "$plugin_dir/scripts/"*

omarchy plugin validate "$plugin_dir"
omarchy-shell shell rescanPlugins >/dev/null
omarchy plugin enable "$plugin_id" >/dev/null || true

cp -a "$plugin_dir/hypr/niri-workspaces.lua" "$hypr_target"

if ! grep -q 'require("hypr.niri-workspaces")' "$hyprland_lua" 2>/dev/null; then
  python - "$hyprland_lua" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
s = p.read_text()
needle = 'require("hypr.looknfeel")\n'
insert = 'require("hypr.looknfeel")\nrequire("hypr.niri-workspaces")\n'
if needle in s:
    s = s.replace(needle, insert, 1)
else:
    s += '\nrequire("hypr.niri-workspaces")\n'
p.write_text(s)
PY
fi

hyprctl reload || true
omarchy restart shell || true

echo "Installed $plugin_id. Use SUPER+GRAVE or the top-left hot corner for overview."
