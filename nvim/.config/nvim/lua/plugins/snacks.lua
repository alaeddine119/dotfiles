-- ========================================================================== --
--  PLUGIN: SNACKS.NVIM
--  Utility collection for Notifier, Terminal, LazyGit, and UI Toggles.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/folke/snacks.nvim" })

-- 2. GUARD
local ok, snacks = pcall(require, "snacks")
if not ok then
	return
end

-- 3. CONFIGURE
snacks.setup({
	notifier = { enabled = true, timeout = 3000 },
	terminal = { enabled = true },
	lazygit = { enabled = true },
	bigfile = { enabled = true },
	quickfile = { enabled = true },
	input = { enabled = true },
	words = { enabled = true },
	statuscolumn = { enabled = true },
})

-- 4. DEBUG GLOBALS & UI TOGGLES
_G.dd = function(...)
	snacks.debug.inspect(...)
end
_G.bt = function(...)
	snacks.debug.backtrace(...)
end

local t = snacks.toggle
t.option("spell", { name = "Spelling" }):map("<leader>ts")
t.option("wrap", { name = "Wrap" }):map("<leader>tW")
t.line_number():map("<leader>tl")

-- 5. KEYMAPS (Wrapped in functions to avoid "got table" error)
local map = function(mode, keys, func, desc)
	vim.keymap.set(mode, keys, func, { desc = "Snacks: " .. desc })
end

local snack_maps = {
	-- [B]uffers & [C]ode
	{
		"n",
		"<leader>bd",
		function()
			snacks.bufdelete()
		end,
		"Delete Buffer",
	},
	{
		"n",
		"<leader>b.",
		function()
			snacks.scratch()
		end,
		"Scratch Buffer",
	},
	{
		"n",
		"<leader>cr",
		function()
			snacks.rename.rename_file()
		end,
		"Rename File",
	},

	-- [G]it & [T]erminal
	{
		"n",
		"<leader>gg",
		function()
			snacks.lazygit()
		end,
		"Lazygit",
	},
	{
		"n",
		"<leader>gb",
		function()
			snacks.gitbrowse()
		end,
		"Git Browse",
	},
	{
		{ "n", "t" },
		"<c-/>",
		function()
			snacks.terminal()
		end,
		"Toggle Terminal",
	},
	{
		{ "n", "t" },
		"<c-_>",
		function()
			snacks.terminal()
		end,
		"Toggle Terminal",
	},

	-- [N]otifications & UI
	{
		"n",
		"<leader>nh",
		function()
			snacks.notifier.show_history()
		end,
		"Notify History",
	},
	{
		"n",
		"<leader>nd",
		function()
			snacks.notifier.hide()
		end,
		"Dismiss Notify",
	},
	{
		"n",
		"<leader>z",
		function()
			snacks.zen()
		end,
		"Zen Mode",
	},

	-- LSP Word Navigation
	{
		"n",
		"]]",
		function()
			snacks.words.jump(vim.v.count1)
		end,
		"Next Reference",
	},
	{
		"n",
		"[[",
		function()
			snacks.words.jump(-vim.v.count1)
		end,
		"Prev Reference",
	},
}

for _, m in ipairs(snack_maps) do
	map(m[1], m[2], m[3], m[4])
end
