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

  -- 2. Tokyo Night (not active — lazy-loaded, only fetched on :colorscheme)
  {
    "folke/tokyonight.nvim",
    lazy = true,
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

  -- 3. Kanagawa (not active — lazy-loaded, only fetched on :colorscheme)
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
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
