-- bootstrap lazy.nvim, LazyVim and your plugins
require("modules.dotenv").load()
require("config.lazy")

-- Start silent background auto-updater
require("modules.updater").setup()

-- GUI (Neovide) settings
require("modules.neovide").setup()

-- Custom integrations (no third-party plugin; commands + autocmds only)
require("modules.kimish").setup()
require("modules.yazi").setup()
