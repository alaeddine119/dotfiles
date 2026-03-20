-- ========================================================================== --
--  CORE OPTIONS
-- ========================================================================== --

-- Globals
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Visuals
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.colorcolumn = "80"
vim.o.textwidth = 80
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.scrolloff = 8
vim.o.splitright = true
vim.o.splitbelow = true
vim.opt.formatoptions:append("tc")

-- Tabs & Indentation
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true

-- Behavior & Interaction
vim.o.mouse = "a"
vim.o.undofile = true
vim.o.confirm = true
vim.opt.completeopt = ""

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.filetype.add({
	filename = { [".blerc"] = "bash" },
})

-- Autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
