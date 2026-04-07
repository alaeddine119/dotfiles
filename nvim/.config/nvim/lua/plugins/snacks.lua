-- ========================================================================== --
--  PLUGIN: SNACKS.NVIM
-- ========================================================================== --

vim.pack.add({ "https://github.com/folke/snacks.nvim" })

local ok, snacks = pcall(require, "snacks")
if not ok then
	return
end

snacks.setup({
	notifier = { enabled = true },
	terminal = { enabled = true },
	lazygit = { enabled = true },
	bigfile = { enabled = true },
	quickfile = { enabled = true },
	input = { enabled = true },
	words = { enabled = true },
	statuscolumn = { enabled = true },
	picker = {
		enabled = true,
		sources = { files = { hidden = true } },
	},
	dashboard = { enabled = false },
})

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
