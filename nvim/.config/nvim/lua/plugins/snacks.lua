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
	terminal = {
		enabled = true,
		win = {
			position = "float",
			border = "rounded",
			width = 0.8,
			height = 0.8,
		},
	},
	lazygit = { enabled = true },
	bigfile = { enabled = true },
	quickfile = { enabled = true },
	input = { enabled = true },
	words = { enabled = true },
	statuscolumn = { enabled = true },
	picker = {
		enabled = true,
		sources = {
			files = { hidden = true },
			explorer = {
				layout = {
					layout = {
						position = "right", -- Dock it to the left or "right"
						min_width = 25, -- Ensures it doesn't squish when resizing Vim
					},
				},
				win = {
					list = {
						-- Options: "none", "single", "double", "rounded", "solid", "shadow"
						border = "none",
					},
				},
			},
		},
	},
	dashboard = { enabled = false },
	explorer = {
		enabled = true,
		replace_netrw = false, -- Keeps Oil in charge of standard directory openings
	},
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
