-- Browser types
hl.window_rule({
  match = { class = "((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[bB]rave-origin|com.brave.Origin|[mM]icrosoft-edge|Vivaldi-stable|helium)" },
  tag = "+chromium-based-browser",
})
hl.window_rule({
  match = { class = "([fF]irefox|zen|librewolf)" },
  tag = "+firefox-based-browser",
})

-- Video apps: remove chromium browser tag so they don't inherit browser tiling
hl.window_rule({
  match = { class = "(chrome-youtube.com__-Default|chrome-app.zoom.us__wc_home-Default)" },
  tag = "-chromium-based-browser",
})

-- Force chromium-based browsers into a tile to deal with --app bug
hl.window_rule({
  match = { tag = "chromium-based-browser" },
  tile = true,
})
