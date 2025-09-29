return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha", -- or your choice
      custom_highlights = function(colors)
        return {
          Comment = { fg = colors.green, italic = true },
        }
      end,
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
