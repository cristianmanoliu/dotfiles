# Changelog

## 2026-06-12 — Go developer setup review fixes

Full config review found one critical bug and several Go-workflow gaps.
All fixes applied in this change. Backup of the pre-fix config:
`~/.config/nvim-backup-2026-06-12-124746.tar.gz`. The pre-fix state is also
preserved as the initial git commit (`2fbd1aa`).

### Critical

- **`lua/plugins/go-lsp.lua` rewritten.** The old version defined
  `config = function()` on `nvim-lspconfig`, which replaced LazyVim's entire
  LSP bootstrap (lazy.nvim: last `config` wins). Result: every LSP except the
  hand-rolled gopls was silently dead — pyright, lua_ls, jsonls, yamlls,
  marksman, taplo all failed to attach (verified: opening a `.py` file
  attached zero clients). It also downgraded gopls versus the `lang.go`
  extra's settings (lost codelenses, inlay hints, nilness/unusedwrite/useany
  analyses, semanticTokens workaround) and duplicated LazyVim's default LSP
  keymaps. The new file extends via `opts.servers.gopls` only, adding the one
  setting the extra lacks: `analyses.shadow = true`.
  Verified after fix: pyright + ruff attach on Python files; gopls attaches
  with both `shadow=true` and the extra's defaults (nilness, staticcheck,
  codelenses) merged.

### Go workflow

- **Debugging enabled.** Deleted `lua/plugins/disable-dap.lua` and added
  `lazyvim.plugins.extras.dap.core` to `lazyvim.json`. delve was already
  installed (Mason + `~/go/bin/dlv`); nvim-dap-go now wires it up.
  Keymaps under `<leader>d` (breakpoint: `<leader>db`, continue: `<leader>dc`).
- **Test runner enabled.** Added `lazyvim.plugins.extras.test.core` to
  `lazyvim.json`. neotest + neotest-golang installed. Keymaps under
  `<leader>t` (run nearest: `<leader>tr`, run file: `<leader>tt`).
- **golangci-lint upgraded 2.6.2 → 2.12.2** via Mason. The old binary was
  built with go1.25 and failed with exit code 3 ("the Go language version
  (go1.25) used to build golangci-lint is lower than the targeted Go version
  (1.26)") on any go1.26 module. Verified: lint now runs and reports findings.
- **`go.nvim` lazy-loading fixed** (`lua/plugins/go-tools.lua`): removed
  `event = "CmdlineEnter"`, which loaded the plugin as soon as `:` was typed
  in any buffer. Now loads on Go filetypes only. Kept for
  `GoAddTag`/`GoRmTag`/`GoIfErr`/`GoImpl`.
- **Run keymap fixed** (`lua/config/keymaps.lua`): `<leader>r` now uses
  `go run .` instead of `go run <file>`, so multi-file packages build. The
  old `<leader>rn` mapping that shadowed `<leader>r` (timeout delay on every
  press) is gone with the go-lsp.lua rewrite; rename is LazyVim's `<leader>cr`.

### Housekeeping

- **Broken pylsp removed.** Mason's `python-lsp-server` venv was dead — every
  Python file open spawned a "language server not installed/executable" error
  (previously masked because all LSP was broken). pyright + ruff cover Python.
- **Config is now a git repo.** `git init`, baseline commit of the pre-fix
  state, then this change as a second commit.
- Deleted stale `lazy-lock.json.bak`.
- Moved `lua/plugins/config.yaml` → `markdownlint.yaml` (config root); it is
  a markdownlint config, not a plugin spec. Updated the reference in
  `lua/plugins/vim-lint-config.lua`.
- Colorschemes: catppuccin stays eager (active scheme); tokyonight and
  kanagawa switched to `lazy = true` so the two unused themes no longer load
  at startup.

### Verification performed

- Headless boot: clean, no errors.
- Python file: pyright + ruff attach (previously zero clients).
- Go file: gopls attaches with merged settings (`shadow`, `nilness`,
  `staticcheck`, codelenses all true).
- golangci-lint: direct run on a go1.26 module exits 1 with a real finding
  (previously exit 3 hard failure).
