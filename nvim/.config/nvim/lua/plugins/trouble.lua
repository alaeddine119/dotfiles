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
local status, trouble = pcall(require, "trouble")
if not status then
	return
end

-- 3. CONFIGURE
trouble.setup({
	-- We keep defaults as requested.
	-- Trouble v3 defaults are excellent out of the box.
	focus = true,
})

-- 4. KEYMAPS (Global triggers)
-- Diagnostics (Project)
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble: Diagnostics (Project)" })

-- Diagnostics (Current Buffer)
vim.keymap.set(
	"n",
	"<leader>xX",
	"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
	{ desc = "Trouble: Diagnostics (Buffer)" }
)

-- Symbols (Like an outline)
vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Trouble: Symbols" })

-- LSP References/Definitions
vim.keymap.set(
	"n",
	"<leader>cl",
	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "Trouble: LSP Definitions/Refs" }
)

-- Location List
vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Trouble: Location List" })

-- Quickfix List
vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Trouble: Quickfix List" })
