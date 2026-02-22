-- Ekon language support for Neovim
-- Ekon is a human-friendly JSON superset
-- https://github.com/Himujjal/ekon-zig

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

      -- Set up Ekon filetype settings
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
    end,
  },

  -- Custom command to manually install/update the parser
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      {
        "nvim-lua/plenary.nvim",
        config = function()
          vim.api.nvim_create_user_command("EkonInstallParser", function()
            local parser_src = vim.fn.expand("~/projects/ekon-zig/tree-sitter-ekon")
            local cc = vim.fn.getenv("CC") or "gcc"

            -- Check if source exists
            if vim.fn.isdirectory(parser_src) == 0 then
              vim.notify("Ekon parser source not found at: " .. parser_src, vim.log.levels.ERROR)
              return
            end

            -- Check if parser.c exists
            local parser_c = parser_src .. "/src/parser.c"
            if vim.fn.filereadable(parser_c) == 0 then
              vim.notify("parser.c not found. Run 'tree-sitter generate' first.", vim.log.levels.ERROR)
              return
            end

            -- Define destinations
            local parser_dest_nvim = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser/ekon.so"
            local parser_dest_site = vim.fn.stdpath("data") .. "/site/parser/ekon.so"
            local queries_dest_nvim = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/queries/ekon"
            local queries_dest_site = vim.fn.stdpath("data") .. "/site/queries/ekon"

            -- Compile the parser
            local cmd = {
              cc,
              "-shared",
              "-fPIC",
              "-g",
              "-O2",
              "-I" .. parser_src .. "/src",
              parser_c,
              "-o",
              parser_dest_nvim,
            }

            vim.notify("Compiling Ekon parser...", vim.log.levels.INFO)
            local output = vim.fn.system(cmd)

            if vim.v.shell_error ~= 0 then
              vim.notify("Failed to compile Ekon parser:\n" .. output, vim.log.levels.ERROR)
              return
            end

            -- Copy to site parser directory (needed for runtime path)
            vim.fn.mkdir(vim.fn.stdpath("data") .. "/site/parser", "p")
            local copy_cmd = { "cp", parser_dest_nvim, parser_dest_site }
            vim.fn.system(copy_cmd)

            -- Copy queries to both locations
            local queries_src = vim.fn.expand("~/projects/ekon-zig/tree-sitter-ekon/queries")
            if vim.fn.isdirectory(queries_src) == 1 then
              vim.fn.mkdir(queries_dest_nvim, "p")
              vim.fn.mkdir(queries_dest_site, "p")
              for _, file in ipairs(vim.fn.glob(queries_src .. "/*.scm", false, true)) do
                vim.fn.system({ "cp", file, queries_dest_nvim .. "/" })
                vim.fn.system({ "cp", file, queries_dest_site .. "/" })
              end
            end

            -- Create parser-info file
            local info_dest = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser-info/ekon.revision"
            vim.fn.mkdir(vim.fn.fnamemodify(info_dest, ":h"), "p")
            local info_file = io.open(info_dest, "w")
            if info_file then
              info_file:write("local")
              info_file:close()
            end

            vim.notify("Ekon parser installed successfully!", vim.log.levels.INFO)

            -- Reload buffer to apply highlighting
            vim.cmd("edit!")
          end, {
            desc = "Manually compile and install the Ekon tree-sitter parser",
          })
        end,
      },
    },
  },
}
