-- ========================================================================== --
--  PLUGIN: OIL.NVIM
--  Edit your filesystem like a normal buffer. Replaces Netrw.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-mini/mini.icons",
	"https://github.com/refractalize/oil-git-status.nvim",
})

-- 2. GUARD
local ok, oil = pcall(require, "oil")
if not ok then
	return
end

-- 3. CONFIGURE
oil.setup({
	columns = { "icon" },
	view_options = { show_hidden = true },
	win_options = { signcolumn = "yes:2" }, -- Required for git status alignment
})

-- 4. CONFIGURE GIT STATUS
local ok_git, oil_git = pcall(require, "oil-git-status")
if ok_git then
	oil_git.setup({ show_ignored = true }) -- Symbols default to ASCII; no need to redefine them
end

-- 5. KEYMAPS
local map = vim.keymap.set
map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
map("n", "<leader><leader>", "<CMD>Oil<CR>", { desc = "Open File Explorer" })
map("n", "<leader>-", oil.toggle_float, { desc = "Floating explorer" })
