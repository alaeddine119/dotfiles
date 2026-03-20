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
	picker = {
		enabled = true,
	},
	dashboard = {
		enabled = true,
		sections = {
			{ section = "header" },
			{
				icon = " ",
				title = "Keymaps",
				section = "keys",
				indent = 2,
				padding = 1,
			},
			{
				icon = " ",
				title = "Recent Files",
				section = "recent_files",
				indent = 2,
				padding = 1,
			},
			{
				icon = " ",
				title = "Projects",
				section = "projects",
				indent = 2,
				padding = 1,
			},
		},
	},
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
