-- ~/.config/nvim/init.lua

-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- 1. CORE CONFIGURATION (Must load first)
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- 2. LOAD PLUGINS

-- Explicit requires are faster than disk-scanning loops,
-- and ensure your priority plugins boot in the exact order you want.

-- Priority
require("plugins.colorscheme")
require("plugins.lsp")

-- Core Tools
require("plugins.blink")
require("plugins.conform")
require("plugins.fidget")
require("plugins.gitsigns")
require("plugins.lint")
require("plugins.mini")
require("plugins.oil")
require("plugins.snacks")
require("plugins.treesitter")
require("plugins.bidi")

-- Utilities
require("plugins.pack-cleaner")
require("plugins.render-markdown")
require("plugins.tmux-navigator")
require("plugins.tpipeline")
require("plugins.trouble")
require("plugins.undotree")
