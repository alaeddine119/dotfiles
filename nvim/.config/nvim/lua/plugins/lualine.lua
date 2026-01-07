-- ========================================================================== --
--  PLUGIN: LUALINE
--  A blazing fast and easy to configure neovim statusline.
-- ========================================================================== --

-- 1. Install
vim.pack.add({
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons", -- Required for icons
})

-- 2. Guard
local status, lualine = pcall(require, "lualine")
if not status then
	return
end

-- 3. Configure
lualine.setup({
	options = {
		theme = "rose-pine", -- Matches your colorscheme
		globalstatus = true, -- One statusline for all splits (Cleaner)

		-- We disable the 'component_separators' to make it look cleaner in Tmux
		component_separators = "|",
		section_separators = "",
	},
	sections = {
		-- This is where Line (l), Column (c), and Percent (p) are defined
		lualine_z = { "location" },
	},
})
