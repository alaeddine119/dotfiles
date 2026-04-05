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
	file_types = { "markdown" },
	render_modes = { "n", "c" }, -- Render in Normal and Command modes
})
