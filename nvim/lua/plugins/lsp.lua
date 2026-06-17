return {
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.biome)

      -- Add custom biome formatter for ek files
      table.insert(
        opts.sources,
        nls.builtins.formatting.biome.with({
          filetypes = { "ek" },
        })
      )

      -- Add markdown formatter
      table.insert(
        opts.sources,
        nls.builtins.formatting.prettierd.with({
          filetypes = { "markdown" },
        })
      )
    end,
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      local api = vim.api
      if api.nvim_get_commands({}).LspInfo then
        return
      end

      local function complete_servers(arg)
        local configs = require("lspconfig.configs")
        return vim.tbl_filter(function(s)
          return s:sub(1, #arg) == arg
        end, vim.tbl_keys(configs))
      end

      local function complete_clients(arg)
        local names = vim.tbl_map(function(c)
          return c.name
        end, vim.lsp.get_clients())
        return vim.tbl_filter(function(s)
          return s:sub(1, #arg) == arg
        end, names)
      end

      api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", { desc = "Alias to `:checkhealth vim.lsp`" })
      api.nvim_create_user_command("LspRestart", function(info)
        if info.args and info.args ~= "" then
          vim.cmd("lsp restart " .. info.args)
        else
          vim.cmd("lsp restart")
        end
      end, { desc = "Restart the given language client(s)", nargs = "?", complete = complete_clients })
      api.nvim_create_user_command("LspStart", function(info)
        if info.args and info.args ~= "" then
          vim.lsp.enable(info.args)
        end
      end, { desc = "Enable and launch a language server", nargs = "?", complete = complete_servers })

      api.nvim_create_user_command("LspLog", function()
        vim.cmd(string.format("tabnew %s", vim.lsp.log.get_filename()))
      end, { desc = "Opens the Nvim LSP client log." })

      api.nvim_create_user_command("LspStop", function(info)
        if info.args and info.args ~= "" then
          vim.cmd("lsp stop " .. info.args)
        else
          vim.cmd("lsp stop")
        end
      end, { desc = "Disable and stop the given language client(s)", nargs = "?", complete = complete_clients })
    end,
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        biome = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "json",
            "jsonc",
            "typescript",
            "typescriptreact",
          },
        },
        jsonls = {},
        lua_ls = {},
        marksman = {},
        oxlint = {},
        pyright = {},
        shfmt = {},
        stylua = {},
        tailwindcss = {},
        vtsls = {},
        zls = {},
        html_lsp = {},
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "zig",
        "go",
      },
    },
  },
}
