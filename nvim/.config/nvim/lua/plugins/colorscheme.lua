-- ========================================================================== --
--  PLUGIN: ROSE PINE
-- ========================================================================== --

-- 1. Install the plugin using Neovim's native package manager.
vim.pack.add({
	-- The URL of the repository to install.
	"https://github.com/rose-pine/neovim",
})

-- 2. Configure the theme before loading it.
require("rose-pine").setup({
	variant = "moon",
	-- Define styles for different syntax elements.
	styles = {
		bold = true, -- Enable bold text.
		italic = false, -- Disable italics (Fixes font rendering/ligature issues).
		transparency = false, -- Disable transparency (use solid background).
	},
	-- Override specific colors in the palette.
	palette = {
		-- We are customizing the "moon" variant specifically.
		moon = {
			base = "#000000", -- Darker background color.
			surface = "#000000", -- Darker background for status bars and menus.
			muted = "#BBBBBB", -- Color for comments/ignored text.
			subtle = "#CCCCCC", -- Color for subtle indicators.
			text = "#E0E0E0", -- Main text color.
			overlay = "#121212", -- Main color for highliting
			highlight_low = "#000000",
			highlight_med = "#444444",
		},
	},
})
-- 3. Actually apply the colorscheme to Neovim.
--    This command must run after the setup() call above.
vim.cmd("colorscheme rose-pine-moon")
