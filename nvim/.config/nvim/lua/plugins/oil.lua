-- ========================================================================== --
--  PLUGIN: OIL.NVIM
--  Edit your filesystem like a normal buffer. Replaces Netrw.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-mini/mini.icons",
	"https://github.com/JezerM/oil-lsp-diagnostics.nvim",
	"https://github.com/malewicz1337/oil-git.nvim",
})

-- 2. GUARD
local ok, oil = pcall(require, "oil")
if not ok then
	return
end

-- 3. CONFIGURE
local detail = false
oil.setup({
	columns = {
		"icon",
		-- "permissions",
		-- "size",
		-- "mtime",
	},
	view_options = { show_hidden = true },
	win_options = { signcolumn = "yes:2" }, -- Required for git status alignment
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

-- 4. CONFIGURE GIT STATUS
local ok_lsp, oil_lsp = pcall(require, "oil-lsp-diagnostics")
if ok_lsp then
	oil_lsp.setup({})
end
local ok_git, oil_git = pcall(require, "oil-git")
if ok_git then
	oil_git.setup({ show_ignored = true }) -- Symbols default to ASCII; no need to redefine them
end
