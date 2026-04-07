-- ========================================================================== --
--  PLUGIN: RENDER-MARKDOWN
-- ========================================================================== --

vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

local status, markdown = pcall(require, "render-markdown")
if not status then
	return
end

markdown.setup()
