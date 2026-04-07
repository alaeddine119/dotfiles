-- ========================================================================== --
--  PLUGIN: OIL.NVIM
-- ========================================================================== --

vim.pack.add({
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-mini/mini.icons",
})

local ok, oil = pcall(require, "oil")
if not ok then
	return
end

local detail = false
oil.setup({
	view_options = { show_hidden = true },
	win_options = { signcolumn = "yes:2" },
	keymaps = {
		["gd"] = {
			desc = "Toggle file detail view",
			callback = function()
				detail = not detail
				if detail then
					require("oil").set_columns({
						"icon",
						"permissions",
						"size",
						"mtime",
					})
				else
					require("oil").set_columns({ "icon" })
				end
			end,
		},
	},
})
