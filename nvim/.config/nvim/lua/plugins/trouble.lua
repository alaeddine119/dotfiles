-- ========================================================================== --
--  PLUGIN: TROUBLE
--  A pretty list for showing diagnostics, references, telescope results, etc.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/folke/trouble.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
})

-- 2. GUARD
local ok, trouble = pcall(require, "trouble")
if not ok then
	return
end

-- 3. CONFIGURE
trouble.setup({ focus = true })

-- 4. KEYMAPS
local map = function(keys, cmd, desc)
	vim.keymap.set("n", keys, "<cmd>Trouble " .. cmd .. "<cr>", { desc = desc })
end

map("<leader>xx", "diagnostics toggle", "Project Diagnostics")
map("<leader>xX", "diagnostics toggle filter.buf=0", "Buffer Diagnostics")
map("<leader>cs", "symbols toggle focus=false", "Symbols")
map("<leader>cl", "lsp toggle focus=false win.position=right", "LSP References")
map("<leader>xL", "loclist toggle", "Location List")
map("<leader>xQ", "qflist toggle", "Quickfix List")
