-- ========================================================================== --
--  PLUGIN: SNACKS.NVIM
--  A collection of QoL plugins.
--  We use this for Lazygit, Terminal, Notifier (messages), and Utils.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/folke/snacks.nvim",
})

-- 2. GUARD
local status, snacks = pcall(require, "snacks")
if not status then
	return
end

-- 3. CONFIGURE MODULES
--    We explicitly disable things covered by your other plugins (Telescope, Oil, Mini).
snacks.setup({
	-- === ENABLED MODULES ===

	-- Pretty notifications (replaces vim.notify)
	-- This handles system messages (like "File Saved").
	-- Your 'fidget.nvim' will still handle LSP Progress (spinning circle).
	notifier = {
		enabled = true,
		timeout = 3000,
	},

	-- Beautiful Floating Terminal & LazyGit Integration
	terminal = { enabled = true },
	lazygit = { enabled = true },

	-- Optimization & Utils
	bigfile = { enabled = true }, -- Prevents freezing on large files
	quickfile = { enabled = true }, -- Speeds up startup
	input = { enabled = true }, -- Better vim.ui.input (renaming files etc)
	words = { enabled = true }, -- Auto-highlight LSP references (cursor hold)
	statuscolumn = { enabled = true }, -- Prettier line numbers/signs column

	-- === DISABLED MODULES (Use your existing plugins instead) ===

	dashboard = { enabled = false }, -- You didn't want this
	scroll = { enabled = false }, -- You use mini.animate
	indent = { enabled = false }, -- You use mini.indentscope
	scope = { enabled = false }, -- You use mini.indentscope
	picker = { enabled = false }, -- You use Telescope
	explorer = { enabled = false }, -- You use Oil.nvim
})

-- 4. KEYMAPS
--    We map these manually since we aren't using lazy.nvim's 'keys' table.

local map = vim.keymap.set

-- Top Level Utils
map("n", "<leader>z", function()
	snacks.zen()
end, { desc = "Toggle Zen Mode" })
map("n", "<leader>.", function()
	snacks.scratch()
end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>bd", function()
	snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>cR", function()
	snacks.rename.rename_file()
end, { desc = "Rename File" })
map("n", "<leader>gB", function()
	snacks.gitbrowse()
end, { desc = "Git Browse" })

-- Notification History
map("n", "<leader>n", function()
	snacks.notifier.show_history()
end, { desc = "Notification History" })
map("n", "<leader>un", function()
	snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })

-- Git / Terminal (The features you wanted!)
map("n", "<leader>gg", function()
	snacks.lazygit()
end, { desc = "Lazygit" })
map({ "n", "t" }, "<c-/>", function()
	snacks.terminal()
end, { desc = "Toggle Terminal" })

-- Word Navigation (Jumps between highlighted references)
map({ "n", "t" }, "]]", function()
	snacks.words.jump(vim.v.count1)
end, { desc = "Next Reference" })
map({ "n", "t" }, "[[", function()
	snacks.words.jump(-vim.v.count1)
end, { desc = "Prev Reference" })

-- 5. INIT (Debug globals and Toggles)
--    Equivalent to the 'init' block in lazy.nvim
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		-- Debug globals (dd() to print table, bt() for backtrace)
		_G.dd = function(...)
			snacks.debug.inspect(...)
		end
		_G.bt = function(...)
			snacks.debug.backtrace(...)
		end

		-- Create Toggle Mappings (e.g. <leader>us to toggle spelling)
		snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
		snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
		snacks.toggle.line_number():map("<leader>ul")
		snacks.toggle.diagnostics():map("<leader>ud")
		snacks.toggle.dim():map("<leader>uD")
	end,
})
