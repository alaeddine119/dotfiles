-- ========================================================================== --
--  PLUGIN: TROUBLE
--  A pretty list for showing diagnostics, references, telescope results, etc.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/folke/trouble.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
})

-- 2. GUARD
local ok, trouble = pcall(require, "trouble")
if not ok then
	return
end

-- 3. CONFIGURE
trouble.setup({ focus = true })
