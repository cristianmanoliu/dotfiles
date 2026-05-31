-- Seamless navigation + resize across nvim splits <-> tmux/WezTerm panes.
-- Pairs with the tmux @plugin 'mrjones2014/smart-splits.nvim' and the
-- smart_splits.apply_to_config() block in ~/.wezterm.lua.
return {
  "mrjones2014/smart-splits.nvim",
  lazy = false, -- load at startup so the @pane-is-vim tmux flag is set immediately
  opts = {},
  keys = {
    -- move
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },
    -- resize
    { "<M-h>", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
    { "<M-j>", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
    { "<M-k>", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
    { "<M-l>", function() require("smart-splits").resize_right() end, desc = "Resize split right" },
  },
}
