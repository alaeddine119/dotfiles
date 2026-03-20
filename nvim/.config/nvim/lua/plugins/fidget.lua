-- ========================================================================== --
--  PLUGIN: Fidget
--  Extensible UI for Neovim notifications and LSP progress messages.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/j-hui/fidget.nvim" })

-- 2. GUARD
local status, fidget = pcall(require, "fidget")
if not status then
	return
end

-- 3. SETUP
fidget.setup({})
