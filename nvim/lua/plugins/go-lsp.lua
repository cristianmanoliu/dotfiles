-- Extra gopls tweaks on top of the lang.go extra.
-- IMPORTANT: extend via `opts` only — defining `config` here would replace
-- LazyVim's nvim-lspconfig bootstrap and silently disable every other LSP.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      gopls = {
        settings = {
          gopls = {
            analyses = { shadow = true },
          },
        },
      },
    },
  },
}
