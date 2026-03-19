-- ========================================================================== --
--  PLUGIN: TREESITTER
-- ========================================================================== --

-- 1. Install Treesitter
vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "master",
	},
	"https://github.com/nvim-treesitter/nvim-treesitter-context",
	"https://github.com/windwp/nvim-ts-autotag",
	"https://github.com/NvChad/nvim-colorizer.lua",
})

-- 2. Guarded Configuration
local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
	return
end

-- 3. Configure (Only runs if plugin is found)
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
	},
	sync_install = false,
	ignore_install = {},
	modules = {},
	auto_install = true,

	highlight = { enable = true },
	indent = { enable = true },

	-- ==================================================== --
	-- THE NEW MODULE: Incremental Selection
	-- ==================================================== --
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-space>", -- Start selecting
			node_incremental = "<C-space>", -- Expand to parent node
			scope_incremental = false, -- (Optional) Expand to parent scope
			node_decremental = "<bs>", -- Shrink selection back down
		},
	},
})

-- [FIXED]: Keymap moved OUTSIDE the setup table!
vim.keymap.set("n", "[c", function()
	require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "Jump to [C]ontext" })

-- 4. Force Treesitter features
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "bash", "c", "diff", "html", "lua", "markdown", "rust", "vim" },
	callback = function()
		local ts_ok, _ = pcall(vim.treesitter.start)
		if ts_ok then
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

-- Use treesitter to autoclose and autorename html tag
require("nvim-ts-autotag").setup()

-- Visual Color Previews (Tailwind & CSS)
require("colorizer").setup({
	user_default_options = {
		tailwind = true, -- Enable tailwind colors
		mode = "background", -- Show color as background of the text
	},
})
