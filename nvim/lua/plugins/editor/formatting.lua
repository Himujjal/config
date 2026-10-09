return {
  {
    "conform.nvim",
    opts = {
      formatters = {
        -- Use the mason-installed oxfmt binary instead of node_modules
        oxfmt = {
          command = vim.fn.stdpath("data") .. "/mason/bin/oxfmt",
        },
        -- Custom SVG formatter that reuses the HTML formatter logic
        -- SVG is XML-based and is best formatted with an HTML/XML parser.
        -- This inherits from `prettier` and forces `--parser html` so SVG
        -- gets HTML-style formatting even though no dedicated SVG formatter exists.
        -- See: https://github.com/stevearc/conform.nvim#customizing-formatters (inherit)
        svg_html = {
          inherit = "prettier",
          args = { "--parser", "html", "--stdin-filepath", "$FILENAME" },
        },
      },
      formatters_by_ft = {
        json = { "oxfmt" },
        jsonc = { "oxfmt" },
        javascript = { "oxfmt" },
        javascriptreact = { "oxfmt" },
        typescript = { "oxfmt" },
        typescriptreact = { "oxfmt" },
        -- No formatter was configured for SVG before (answer to your question).
        -- Use custom html-based formatter, with `xmllint` as fallback (available at /usr/bin/xmllint).
        svg = { "svg_html", "xmllint" },
        html = { "prettier", "html_beautify" },
        xml = { "xmllint" },
      },
    },
  },
}
