-- ========================================================================== --
--  PLUGIN: OIL.NVIM
-- ========================================================================== --

vim.pack.add({
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-mini/mini.icons",
	"https://github.com/malewicz1337/oil-git.nvim",
	"https://github.com/JezerM/oil-lsp-diagnostics.nvim",
})

local ok, oil = pcall(require, "oil")
local ok_git, oil_git = pcall(require, "oil-git")
local ok_lsp, oil_lsp = pcall(require, "oil-lsp-diagnostics")
if not ok or not ok_git or not ok_lsp then
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

-- 4. INITIALIZE GIT EXTENSION
oil_git.setup({
	symbol_position = "signcolumn",
})

-- 5. INITIALIZE LSP EXTENSION
oil_lsp.setup({
	count = false,
})
