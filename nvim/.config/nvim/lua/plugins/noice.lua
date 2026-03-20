-- ========================================================================== --
--  PLUGIN: NOICE.NVIM
--  Replaces the UI for messages, cmdline and the popupmenu.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/folke/noice.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
})

-- 2. GUARD
local status, noice = pcall(require, "noice")
if not status then
	return
end

-- 3. CONFIGURE
noice.setup({
	presets = {
		bottom_search = true,
		command_palette = true,
		long_message_to_split = true,
		lsp_doc_border = true,
	},

	notify = { enabled = false }, -- Using snacks.notifier / external
	lsp = {
		progress = { enabled = false }, -- Handled by Fidget
		signature = { enabled = false },
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
	routes = {
		{
			filter = { event = "msg_show", find = "written" },
			opts = { skip = true },
		},
	},
})

-- 4. KEYMAPS
vim.keymap.set("c", "<S-Enter>", function()
	noice.redirect(vim.fn.getcmdline())
end, { desc = "Redirect Cmdline" })
