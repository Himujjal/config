-- bootstrap lazy.nvim, LazyVim and your plugins
require("dotenv").load()
require("config.lazy")

-- Start silent background auto-updater
require("config.updater").setup()

require("neovide")
