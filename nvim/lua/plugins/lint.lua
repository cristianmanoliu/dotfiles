return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        args = { "--config", "/Users/cristianmanoliu/.markdownlint-cli2.yaml", "--" },
      },
    },
  },
}
