-- vhs80 colorscheme (single theme, no switching)
-- Require from init.lua or plugins config if using LazyVim.
return {
  { "tahayvr/vhs80.nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vhs80",
    },
  },
}
