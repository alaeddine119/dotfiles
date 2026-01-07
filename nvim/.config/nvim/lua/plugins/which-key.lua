-- ========================================================================== --
--  PLUGIN: WHICH-KEY
--  Displays a popup with available keybindings as you type.
-- ========================================================================== --

-- 1. Install Plugin & Icons
vim.pack.add({
	"https://github.com/folke/which-key.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons", -- Optional: Adds icons
})

-- 2. Guard (Safety check)
local status, wk = pcall(require, "which-key")
if not status then
	return
end

-- 3. Configure Layout & Position
wk.setup({
	-- Use "modern" preset for the best look with icons
	preset = "modern",

	-- Window Configuration (Bottom-Right Corner)
	win = {
		-- Anchors the window to the Bottom (-1) and Right (-1)
		row = -1,
		col = -1,

		-- Dimensions:
		-- 25% of the screen width (makes it look like a vertical list)
		-- 60% of the screen height (keeps it in the bottom corner)
		width = 0.25,
		height = 0.40,

		-- Visuals
		border = "rounded",
		padding = { 1, 2 }, -- {top/bottom, right/left}
		title = true,
		title_pos = "center",
		zindex = 1000,
	},

	-- Column Layout
	layout = {
		-- Since we are in a narrow column, we limit width and spacing
		width = { min = 15, max = 50 },
		spacing = 3,
		align = "left",
	},
})

-- 4. Register Groups
wk.add({
	-- Leader Groups
	{ "<leader>f", group = "Format" },
	{ "<leader>s", group = "Search" },
	{ "<leader>g", group = "Git" },
	{ "<leader>w", group = "Write/Window" },

	-- G / Comment Mappings
	{ "g", group = "Go / Actions" },
	{ "gc", group = "Comments" },
	{ "gb", group = "Block Comments" },

	-- Navigation
	{ "[", group = "Previous" },
	{ "]", group = "Next" },
})
