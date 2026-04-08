-- ========================================================================== --
--  PLUGIN: TREESITTER
-- ========================================================================== --

vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	"https://github.com/nvim-treesitter/nvim-treesitter-context",
	"https://github.com/NvChad/nvim-colorizer.lua",
})

local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
	return
end

configs.setup({
	ensure_installed = {
		"bash",
		"c",
		"cpp",
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
		"yaml",
		"regex",
		"javascript",
		"typescript",
		"tsx",
		"css",
		"dockerfile",
		"json",
		"sql",
		"embedded_template",
		"matlab",
		"latex",
		"zig",
	},
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-space>",
			node_incremental = "<C-space>",
			node_decremental = "<bs>",
		},
	},
})

vim.keymap.set("n", "[C", function()
	require("treesitter-context").go_to_context(vim.v.count1)
end, { desc = "Jump to [C]ontext" })

require("colorizer").setup({
	user_default_options = { tailwind = true, mode = "background" },
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "bash", "c", "diff", "html", "lua", "markdown", "rust", "vim" },
	callback = function()
		pcall(vim.treesitter.start)
	end,
})
