-- ~/.config/nvim/lua/plugins/disable-arrows.lua
return {
  {
    "LazyVim/LazyVim", -- attach to an existing, always-present plugin
    keys = function()
      -- local modes = { "n", "i", "v", "x", "s", "o", "c", "t" }
      local modes = { "n", "i", "v", "x", "s", "o", "t" }
      local defs = {}
      for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
        table.insert(defs, { key, "<Nop>", mode = modes })
      end
      return defs
    end,
  },
}
