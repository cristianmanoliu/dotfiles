-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Function to compile/run based on file extension
local function run_file()
  local ext = vim.fn.expand("%:e")
  local filename = vim.fn.expand("%:t")
  local basename = vim.fn.expand("%:t:r")
  local cmd = ""

  if ext == "java" then
    cmd = string.format("javac %s && java %s", filename, basename)
  elseif ext == "py" then
    cmd = string.format("python3 %s", filename)
  elseif ext == "sh" then
    cmd = string.format("bash %s", filename)
  elseif ext == "c" then
    cmd = string.format("gcc %s -o %s && ./%s", filename, basename, basename)
  else
    print("No run command defined for ." .. ext .. " files")
    return
  end

  -- vim.cmd("split | terminal " .. cmd)
  -- Run in split terminal and auto-enter Terminal mode
  vim.cmd("split | terminal " .. cmd)
  vim.cmd("startinsert")
end

-- Keymap to run the function
vim.keymap.set("n", "<leader>r", run_file, { desc = "Compile & Run File", silent = true })
