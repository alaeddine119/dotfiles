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

-- [B]uffers
map("n", "<leader>bd", function()
	snacks.bufdelete()
end, { desc = "[B]uffer [D]elete" })
map("n", "<leader>b.", function()
	snacks.scratch()
end, { desc = "[B]uffer Scratch [.]" })

-- [C]ode
map("n", "<leader>cr", function()
	snacks.rename.rename_file()
end, { desc = "[C]ode [R]ename File" })

-- [G]it
map("n", "<leader>gg", function()
	snacks.lazygit()
end, { desc = "[G]it [G]ui (Lazygit)" })
map("n", "<leader>gb", function()
	snacks.gitbrowse()
end, { desc = "[G]it [B]rowse (Web)" })

-- [N]otifications
map("n", "<leader>nh", function()
	snacks.notifier.show_history()
end, { desc = "[N]otification [H]istory" })
map("n", "<leader>nd", function()
	snacks.notifier.hide()
end, { desc = "[N]otification [D]ismiss" })

-- [T]oggles (Misc)
map("n", "<leader>z", function()
	snacks.zen()
end, { desc = "[Z]en Mode" })
map({ "n", "t" }, "<c-/>", function()
	snacks.terminal()
end, { desc = "Toggle Terminal" })

-- Word Navigation
map({ "n", "t" }, "]]", function()
	snacks.words.jump(vim.v.count1)
end, { desc = "Next Reference" })
map({ "n", "t" }, "[[", function()
	snacks.words.jump(-vim.v.count1)
end, { desc = "Prev Reference" })

-- 5. INIT (Debug globals and Toggles)
--    Equivalent to the 'init' block in lazy.nvim
_G.dd = function(...)
	snacks.debug.inspect(...)
end
_G.bt = function(...)
	snacks.debug.backtrace(...)
end

-- Mapped to <leader>t... for Toggles
snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tW")
snacks.toggle.line_number():map("<leader>tl")
snacks.toggle.dim():map("<leader>tD")

-- Toggle Terminal (Handles both Ctrl+/ and Ctrl+_)
map({ "n", "t" }, "<c-/>", function()
	snacks.terminal()
end, { desc = "Toggle Terminal" })

map({ "n", "t" }, "<c-_>", function()
	snacks.terminal()
end, { desc = "Toggle Terminal (Alt)" })
