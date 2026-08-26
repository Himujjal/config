return {
  {
    "conform.nvim",
    opts = {
      formatters = {
        -- Use the mason-installed oxfmt binary instead of node_modules
        oxfmt = {
          command = vim.fn.stdpath("data") .. "/mason/bin/oxfmt",
        },
      },
      formatters_by_ft = {
        json = { "oxfmt" },
        jsonc = { "oxfmt" },
        javascript = { "oxfmt" },
        javascriptreact = { "oxfmt" },
        typescript = { "oxfmt" },
        typescriptreact = { "oxfmt" },
      },
    },
  },
}
