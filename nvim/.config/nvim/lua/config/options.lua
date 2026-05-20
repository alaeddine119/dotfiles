-- ========================================================================== --
--  CORE OPTIONS
-- ========================================================================== --

-- Globals
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Experimental UI2
require("vim._core.ui2").enable({
	enable = true,
	msg = {
		-- Route all standard messages to the bottom cmdline area
		targets = "cmd",
		cmd = {
			-- Expand the cmdline up to half the screen height if needed
			height = 0.5,
		},
	},
})

-- Visuals
vim.o.number = true
vim.o.relativenumber = true
vim.o.linebreak = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.showmode = false
vim.o.colorcolumn = "80"
vim.o.textwidth = 80
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.scrolloff = 8
vim.o.inccommand = "split"
vim.o.splitright = true
vim.o.splitbelow = true

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
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.spell = true
vim.o.laststatus = 3
vim.o.cmdheight = 0

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Configure UI2 specific buffers
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "cmd", "msg", "pager", "dialog" },
	callback = function()
		-- Set local options to keep the UI clean
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.spell = false
	end,
})
