-- ========================================================================== --
--  PLUGIN: Fidget
--  Extensible UI for Neovim notifications and LSP progress messages.
-- ========================================================================== --

-- 1. Install
vim.pack.add({
    'https://github.com/j-hui/fidget.nvim',
})

-- 2. Guard (Prevent crash on first install)
local status, fidget = pcall(require, "fidget")
if not status then return end

-- 3. Setup
fidget.setup({})
