-- ========================================================================== --
--  PLUGIN: BIDI.NVIM
--  Bidirectional (bidi) text support in neovim.
-- ========================================================================== --

-- Install Bidi
vim.pack.add({
	"https://github.com/mcookly/bidi.nvim",
})

-- Setup Bidi
local status, bidi = pcall(require, "bidi")
if not status then
	return
end

bidi.setup({})

-- Add keyboard shortcut
vim.keymap.set("n", "<leader>tb", function()
	if vim.b.bidi_activated then
		vim.cmd("BidiDisable")
		vim.b.bidi_activated = false
		vim.notify("Bidi Layout Disabled", vim.log.levels.INFO)
	else
		vim.cmd("BidiEnable")
		vim.b.bidi_activated = true
		vim.notify("Bidi Layout Enabled", vim.log.levels.INFO)
	end
end, { desc = "Toggle Bidi Layout" })
