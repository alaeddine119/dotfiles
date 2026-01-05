-- Set the global and local leader to space bar
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Nerd Font configuration
vim.g.have_nerd_font = true

-- Tab / Indentation settings
vim.o.tabstop = 4 -- Visual width of a tab
vim.o.softtabstop = 4 -- The number of spaces inserted when hitting Tab
vim.o.shiftwidth = 4 -- Size of an indent
vim.o.expandtab = true -- Convert tabs to spaces

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
vim.o.cursorline = false

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

-- Hook to build plugins that require compilation (like fzf-native)
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name = ev.data.spec.name
		local kind = ev.data.kind

		-- Check if the plugin is fzf-native and if it was just installed or updated
		if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
			print("Building fzf-native...")

			-- Run 'make' synchronously so we know if it fails
			local result = vim.system({ "make" }, { cwd = ev.data.path }):wait()

			if result.code == 0 then
				print("Successfully built fzf-native!")
			else
				print("Failed to build fzf-native: " .. (result.stderr or "unknown error"))
			end
		end
	end,
})

-- Plugins
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
	{
		src = "https://github.com/nvim-telescope/telescope.nvim",
	},
	{
		src = "https://github.com/nvim-lua/plenary.nvim",
	},
	{
		src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
		name = "telescope-fzf-native.nvim",
	},
	{
		src = "https://github.com/nvim-telescope/telescope-ui-select.nvim",
	},
	{
		src = "https://github.com/nvim-tree/nvim-web-devicons",
	},
    {
		src = "https://github.com/folke/lazydev.nvim",
        name = "lazydev.nvim",
	},
})


-- This fixes the "undefined global vim" warning and adds completion for vim.uv
require("lazydev").setup({
        library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
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

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
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

-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
	local file_paths = {}
	for _, item in ipairs(harpoon_files.items) do
		table.insert(file_paths, item.value)
	end

	require("telescope.pickers")
		.new({}, {
			prompt_title = "Harpoon",
			finder = require("telescope.finders").new_table({
				results = file_paths,
			}),
			previewer = conf.file_previewer({}),
			sorter = conf.generic_sorter({}),
		})
		:find()
end

vim.keymap.set("n", "<C-e>", function()
	toggle_telescope(harpoon:list())
end, { desc = "Open harpoon window" })

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

-- Telescope Setup
require("telescope").setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown(),
		},
	},
})

pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })

-- Search files in the directory of the current buffer (similar to :Ex behavior)
vim.keymap.set("n", "<leader>se", function()
  builtin.find_files({
    cwd = vim.fn.expand("%:p:h"), -- Expands to the directory of the current file
    -- depth = 1,                  -- Optional: Un-comment to stop recursion (only show files in this dir)
  })
end, { desc = "[S]earch [E]xplorer (current file directory)" })

vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>",":Ex<CR>" , { desc = "[ ] File Explorder" })

-- Keybinds
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
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
require("rose-pine").setup({
	palette = {
		-- Override the builtin palette per variant
		moon = {
			base = "#121212",
			surface = "#222222",
			muted = "#bbbbbb",
			subtle = "#cccccc",
			text = "#E0E0E0",
		},
	},
})

vim.cmd("colorscheme rose-pine-moon")

-- Diagnostics config
vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = true,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
})
