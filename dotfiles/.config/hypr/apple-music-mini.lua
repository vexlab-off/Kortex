-- Apple Music Mini: keep the webapp renderer alive on the scratchpad /
-- other workspaces so Chromium does not pause <audio> as occluded.
-- Opaque like other media webapps (YouTube), not the default browser dim.
o.window("^.+-music\\.apple\\.com__.*$", {
  tag = "-chromium-based-browser",
})
o.window("^.+-music\\.apple\\.com__.*$", {
  tag = "-default-opacity",
  render_unfocused = true,
})

-- Super+W is Close window everywhere else. For Apple Music, send it to the
-- scratchpad instead so Chromium keeps playing. Opening the full player
-- from the miniplayer moves it onto the current workspace first, so Super+W
-- stashes it the same way as a manual launch. Super+S still toggles the
-- scratchpad. This file is dropped on unapply, so a full Hyprland reload
-- restores the default Super+W bind from Omarchy.
hl.unbind("SUPER + W")
o.bind("SUPER + W", "Close window", function()
  local window = hl.get_active_window()
  local class = window and (window.class or window.initial_class or "") or ""
  if class:find("music.apple.com__", 1, true) then
    hl.dispatch(hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
    return
  end
  hl.dispatch(hl.dsp.window.close())
end)

