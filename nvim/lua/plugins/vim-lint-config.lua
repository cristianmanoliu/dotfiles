return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        args = { "--config", "${HOME}/.config/nvim/lua/plugins/config.yaml", "--" },
      },
    },
  },
}
