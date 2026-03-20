-- ========================================================================== --
--  PLUGIN: UNDOTREE
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/mbbill/undotree" })

-- 2. CONFIGURE UI
vim.g.undotree_WindowLayout = 2
vim.g.undotree_SetFocusWhenToggle = 1

-- 3. KEYMAPS
vim.keymap.set(
	"n",
	"<leader>U",
	vim.cmd.UndotreeToggle,
	{ desc = "UndoTree Toggle" }
)
