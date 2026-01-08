-- ========================================================================== --
--  PLUGIN: OIL.NVIM
--  Edit your filesystem like a normal buffer. Replaces Netrw.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-mini/mini.icons", -- Dependencies
})

-- 2. GUARD
local status, oil = pcall(require, "oil")
if not status then
	return
end

-- 3. CONFIGURE
oil.setup({
	-- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
	default_file_explorer = true,

	-- Columns to display in the list
	columns = {
		"icon",
		-- "permissions",
		-- "size",
		-- "mtime",
	},
	-- View options
	view_options = {
		show_hidden = true,
	},
})

-- 4. KEYMAPS
-- Open parent directory in current window
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
-- Open Oil in floating window (optional, but cool)
vim.keymap.set("n", "<leader><leader>", "<CMD>Oil<CR>", { desc = "Open File Explorer (Oil)" })
-- Open file explorer in a floating window (Optional, nice for quick checks)
vim.keymap.set("n", "<leader>-", require("oil").toggle_float, { desc = "Open floating file explorer" })
