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
--    We attempt to load the plugin. If it fails (installing...), 'ok' will be false.
local ok, configs = pcall(require, "nvim-treesitter.configs")

if not ok then
	-- If the plugin isn't found, stop here.
	-- This prevents the "module not found" error on first install.
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
		"jsx",
		"tsx",
		"css",
		"dockerfile",
		"json",
		"sql",
		"embedded_template", -- For better CSS/SQL in JS handling
		"matlab",
	},
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true },
	-- Keymap: Jump to the context header
	vim.keymap.set("n", "[c", function()
		require("treesitter-context").go_to_context(vim.v.count1)
	end, { silent = true, desc = "Jump to [C]ontext" }),
})

-- 4. Force Treesitter features
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "bash", "c", "diff", "html", "lua", "markdown", "rust", "vim" },
	callback = function()
		-- Use pcall here too, just in case
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
