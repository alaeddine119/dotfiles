-- ========================================================================== --
--  PLUGIN: ROSE PINE
-- ========================================================================== --

vim.pack.add({ "https://github.com/rose-pine/neovim" })

require("rose-pine").setup({
	variant = "moon",
	styles = {
		italic = true,
	},
	palette = {
		moon = {
			base = "#000000",
			surface = "#000000",
			muted = "#BBBBBB",
			subtle = "#CCCCCC",
			text = "#E0E0E0",
			overlay = "#121212",
			highlight_low = "#000000",
			highlight_med = "#444444",
		},
	},
})

vim.cmd("colorscheme rose-pine-moon")
