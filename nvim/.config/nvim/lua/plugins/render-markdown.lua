-- ========================================================================== --
--  PLUGIN: RENDER-MARKDOWN
--  Renders Markdown (headers, tables, checkboxes) prettily in the buffer.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
})

-- 2. GUARD
local status, markdown = pcall(require, "render-markdown")
if not status then
	return
end

-- 3. CONFIGURE
markdown.setup({
	-- basic configuration
	file_types = { "markdown", "Avante", "codecompanion" },
	render_modes = { "n", "c" }, -- Render in Normal and Command modes

	heading = {
		-- Turn the ## into a nice icon and background pill
		sign = false, -- Disable sign column icons to keep it clean
		icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
		position = "overlay", -- Hide the ## symbols
		width = "full", -- Background color spans whole screen (Rose Pine style)
	},

	code = {
		-- Make code blocks look like "blocks" with a subtle background
		sign = false,
		style = "language",
		width = "block",
		right_pad = 1,
		border = "thick",
	},

	checkbox = {
		enabled = true,
		position = "inline",
		unchecked = { icon = "󰄱 " },
		checked = { icon = "󰱒 " },
	},
})
