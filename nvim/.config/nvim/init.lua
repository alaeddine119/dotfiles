-- Set the global and local leader to space bar
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Nerd Font configuration
vim.g.have_nerd_font = true

-- Enable relative line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse support in all modes
vim.o.mouse = 'a'


-- System clipboard integration
vim.schedule(
	function()
		vim.o.clipboard = 'unnamedplus'
	end
)

-- Enable persistent undo
vim.o.undofile = true

-- Highlight horizental line at cursor location
vim.o.cursorline = true

-- Confirmation dialogue
vim.o.confirm = true

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

