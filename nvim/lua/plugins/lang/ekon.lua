-- Ekon language support: a human-friendly JSON superset.
-- https://github.com/Himujjal/ekon-zig
-- Spec is thin: filetype/settings wiring + parser install command (logic lives in modules/ekon).

return {
  -- Filetype detection and settings
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
    config = function()
      -- Register filetype
      vim.filetype.add({
        extension = {
          ekon = "ekon",
        },
        filename = {
          [".ekonrc"] = "ekon",
        },
      })

      -- Ekon filetype settings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "ekon",
        callback = function(args)
          -- Comment format for commentary plugins
          vim.opt_local.commentstring = "// %s"

          -- Indentation (Ekon uses 4 spaces by convention)
          vim.opt_local.expandtab = true
          vim.opt_local.shiftwidth = 4
          vim.opt_local.softtabstop = 4
          vim.opt_local.tabstop = 4

          -- Register and enable tree-sitter highlighting
          local ok, err = pcall(vim.treesitter.language.register, "ekon", "ekon")
          if ok then
            vim.treesitter.start(args.buf, "ekon")
          else
            vim.notify("Ekon parser error: " .. tostring(err), vim.log.levels.WARN)
          end
        end,
      })

      -- `.ek` files: use TypeScript syntax but prevent LSP
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.ek",
        callback = function()
          vim.bo.filetype = "typescript"
          vim.bo.omnifunc = ""
          vim.bo.tagfunc = ""
          vim.bo.formatexpr = ""
        end,
      })

      -- Disable LSP for .ek files by stopping clients after a short delay
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufname = vim.api.nvim_buf_get_name(args.buf)
          if bufname:match("%.ek$") then
            -- Use vim.schedule to avoid race conditions
            vim.schedule(function()
              local clients = vim.lsp.get_clients({ bufnr = args.buf })
              for _, client in ipairs(clients) do
                vim.lsp.buf_detach_client(args.buf, client.id)
              end
            end)
          end
        end,
      })
    end,
  },

  -- Custom command to manually install/update the parser
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      {
        "nvim-lua/plenary.nvim",
        init = function()
          vim.api.nvim_create_user_command("EkonInstallParser", function()
            require("modules.ekon.treesitter").install_parser()
          end, {
            desc = "Manually compile and install the Ekon tree-sitter parser",
          })
        end,
      },
    },
  },
}
