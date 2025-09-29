-- Utility: extract CLI args only if current line has ARGS:
local function extract_args()
  local line = vim.fn.getline(".")
  -- Match ARGS line: supports #, //, --, etc.
  local m = line:match("^%s*[-/#;*]+%s*ARGS:%s*(.+)$")
  if not m then
    m = line:match("^%s*ARGS:%s*(.+)$")
  end
  return m or "" -- empty string if no ARGS on current line
end

-- Main runner: chooses command by extension and appends args only if present
local function run_file()
  local ext = vim.fn.expand("%:e")
  local filename = vim.fn.expand("%:t")
  local basename = vim.fn.expand("%:t:r")

  local args = extract_args()
  local args_part = (args ~= "" and (" " .. args)) or ""

  local cmd
  if ext == "java" then
    cmd = string.format("javac %s && java %s%s", filename, basename, args_part)
  elseif ext == "py" then
    cmd = string.format("python3 %s%s", filename, args_part)
  elseif ext == "sh" then
    cmd = string.format("bash %s%s", filename, args_part)
  elseif ext == "js" then
    cmd = string.format("node %s%s", filename, args_part)
  elseif ext == "c" then
    cmd = string.format("gcc %s -o %s && ./%s%s", filename, basename, basename, args_part)
  else
    print("No run command defined for extension: ." .. (ext or ""))
    return
  end

  -- Run in split terminal and auto-enter Terminal mode
  vim.cmd("split | terminal " .. cmd)
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>r", run_file, { desc = "Compile & Run (ARGS if on line)", silent = true })
