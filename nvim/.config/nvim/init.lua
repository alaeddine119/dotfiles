-- Set the global and local leader to space bar
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Nerd Font configuration
vim.g.have_nerd_font = true

-- Enable relative line numbers
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"

-- Enable mouse support in all modes
vim.o.mouse = "a"

-- System clipboard integration
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Enable persistent undo
vim.o.undofile = true

-- Highlight horizental line at cursor location
vim.o.cursorline = true

-- Confirmation dialogue
vim.o.confirm = true

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Plugins
-- LSP
vim.pack.add({
	{
		src = "https://github.com/neovim/nvim-lspconfig",
	},
	{
		src = "https://github.com/mason-org/mason.nvim",
	},
	{
		src = "https://github.com/mason-org/mason-lspconfig.nvim",
	},
	{
		src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	{
		src = "https://github.com/ThePrimeagen/harpoon",
		version = "harpoon2",
	},
	{
		src = "https://github.com/nvim-lua/plenary.nvim",
	},
	{
		src = "https://github.com/rose-pine/neovim",
	},
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "master",
	},
})

-- Setup Mason
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"stylua",
		"rust-analyzer",
	},
})
-- Treesitter setup
require("nvim-treesitter").install({
	"bash",
	"c",
	"diff",
	"html",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"query",
	"vim",
	"vimdoc",
	"rust",
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 	"bash",
	"c",
	"diff",
	"html",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"query",
	"vim",
	"vimdoc",
	"rust",
 },
    callback = function()
      -- syntax highlighting, provided by Neovim
      vim.treesitter.start()
      -- folds, provided by Neovim
      -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      -- vim.wo.foldmethod = 'expr'
      -- indentation, provided by nvim-treesitter
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })



-- Harpoon setup
local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<leader>e", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<leader>1", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<leader>2", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<leader>3", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<leader>4", function()
	harpoon:list():select(4)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<leader>p", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<leader>n", function()
	harpoon:list():next()
end)

-- Keybinds
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader><leader>", ":Ex<CR>")
vim.keymap.set("n", "<leader>w", ":write<CR>")

-- Completion
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

vim.cmd("set completeopt+=noselect")

-- Color scheme
vim.cmd("colorscheme rose-pine-moon")

-- Diagnostics config
vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = true,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
})
