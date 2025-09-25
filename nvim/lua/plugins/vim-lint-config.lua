return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        args = { "--config", "/Users/cristianmanoliu/.config/nvim/lua/plugins/config.yaml", "--" },
      },
    },
  },
}
