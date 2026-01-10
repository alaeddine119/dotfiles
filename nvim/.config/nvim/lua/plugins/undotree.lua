-- ========================================================================== --
--  PLUGIN: UNDOTREE
--  Visualizes the undo history and branches.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/mbbill/undotree",
})

-- 2. GUARD
--    Undotree is a Vimscript plugin, so we check if the global command exists
--    after the plugin loads. We don't need a specific require guard here.

-- 3. CONFIGURE PERSISTENT UNDO
vim.opt.undofile = true

-- 4. CONFIGURE UI
--    Set layout style (2 = tree on left, diff on bottom)
vim.g.undotree_WindowLayout = 2
--    Focus the file window after selecting a state
vim.g.undotree_SetFocusWhenToggle = 1

-- 5. KEYMAPS
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle UndoTree" })
