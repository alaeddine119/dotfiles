-- ========================================================================== --
--  PLUGIN: OIL.NVIM
-- ========================================================================== --

vim.pack.add({
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-mini/mini.icons",
	"https://github.com/malewicz1337/oil-git.nvim",
})

local ok, oil = pcall(require, "oil")
local ok_git, oil_git = pcall(require, "oil-git")
if not ok or not ok_git then
	return
end

local detail = false
oil.setup({
	view_options = { show_hidden = true },
	win_options = { signcolumn = "yes:1" },
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

-- 4. INITIALIZE GIT EXTENSION SECOND
oil_git.setup({
	show_file_highlights = true,
	show_directory_highlights = true,
	show_ignored_files = false,
	-- 💡 Route the status symbols into your sign column layout
	symbol_position = "signcolumn",
})
