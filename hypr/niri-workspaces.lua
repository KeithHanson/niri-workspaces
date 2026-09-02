-- Optional Hyprland bindings/layout for the niri-workspaces Omarchy plugin.
-- Install by copying this file to ~/.config/hypr/niri-workspaces.lua and adding
-- require("hypr.niri-workspaces") after require("hypr.bindings") in hyprland.lua.

local plugin_dir = os.getenv("HOME") .. "/.config/omarchy/plugins/niri-workspaces"

-- Niri-ish scrolling layout: vertical workspaces, horizontal window strips.
hl.config({
  general = {
    layout = "scrolling",
    gaps_out = { top = 10, right = 10, bottom = 10, left = 52 },
  },
  scrolling = {
    column_width = 0.97,
  },
})

-- Vertical slide between workspace strips.
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slidevert" })

-- Replace Omarchy defaults where they conflict with the niri-ish model.
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")
hl.unbind("SUPER + SHIFT + UP")
hl.unbind("SUPER + SHIFT + DOWN")
hl.unbind("SUPER + ALT + F")
hl.unbind("SUPER + mouse_down")
hl.unbind("SUPER + mouse_up")
hl.unbind("SUPER + SHIFT + mouse_down")
hl.unbind("SUPER + SHIFT + mouse_up")

o.bind("SUPER + GRAVE", "Toggle workspace overview", "omarchy-shell shell call niri-workspaces toggleOverview '{}'")
o.bind("SUPER + ALT + F", "Toggle full-width window", plugin_dir .. "/scripts/hypr-window-full-width")

o.bind("SUPER + UP", "Switch to workspace above", hl.dsp.focus({ workspace = "-1" }))
o.bind("SUPER + DOWN", "Switch to workspace below", hl.dsp.focus({ workspace = "+1" }))
o.bind("SUPER + SHIFT + UP", "Move window to workspace above", hl.dsp.window.move({ workspace = "-1" }))
o.bind("SUPER + SHIFT + DOWN", "Move window to workspace below", hl.dsp.window.move({ workspace = "+1" }))

o.bind("SUPER + mouse_down", "Scroll to next workspace", hl.dsp.focus({ workspace = "+1" }))
o.bind("SUPER + mouse_up", "Scroll to previous workspace", hl.dsp.focus({ workspace = "-1" }))
o.bind("SUPER + SHIFT + mouse_down", "Scroll to window on the right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + SHIFT + mouse_up", "Scroll to window on the left", hl.dsp.focus({ direction = "l" }))
