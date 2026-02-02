return {
  -- 1. Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      transparent_background = false,
      show_end_of_buffer = false,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
      },
    },
  },

  -- 2. Tokyo Night
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night", -- storm, moon, night, day
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
    },
  },

  -- 3. Kanagawa
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      theme = "wave", -- wave, dragon, lotus
      transparent = false,
      terminal_colors = true,
      styles = {
        comment = { italic = true },
        keyword = { italic = true },
      },
    },
  },

  -- Choose your colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin", -- or "tokyonight" or "kanagawa"
    },
  },
}
