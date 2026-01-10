-- ========================================================================== --
--  PLUGIN: OIL.NVIM
--  Edit your filesystem like a normal buffer. Replaces Netrw.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-mini/mini.icons", -- Dependencies
	-- Git status extension for Oil
	"https://github.com/refractalize/oil-git-status.nvim",
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
	-- CRITICAL: Allow 2 sign columns so git status icons fit
	win_options = {
		signcolumn = "yes:2",
	},
})

-- 4. CONFIGURE GIT STATUS
--    We guard this separately in case the main plugin loads but this one fails
local git_status_ok, oil_git_status = pcall(require, "oil-git-status")
if git_status_ok then
	oil_git_status.setup({
		show_ignored = true, -- show ignored files with !!
		symbols = {
			-- Customize symbols if you want (using standard ASCII for now)
			index = {
				["!"] = "!",
				["?"] = "?",
				["A"] = "A",
				["C"] = "C",
				["D"] = "D",
				["M"] = "M",
				["R"] = "R",
				["T"] = "T",
				["U"] = "U",
				[" "] = " ",
			},
			working_tree = {
				["!"] = "!",
				["?"] = "?",
				["A"] = "A",
				["C"] = "C",
				["D"] = "D",
				["M"] = "M",
				["R"] = "R",
				["T"] = "T",
				["U"] = "U",
				[" "] = " ",
			},
		},
	})
end

-- 5. KEYMAPS
-- Open parent directory in current window
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
-- Open Oil in floating window (optional, but cool)
vim.keymap.set("n", "<leader><leader>", "<CMD>Oil<CR>", { desc = "Open File Explorer (Oil)" })
-- Open file explorer in a floating window (Optional, nice for quick checks)
vim.keymap.set("n", "<leader>-", require("oil").toggle_float, { desc = "Open floating file explorer" })
