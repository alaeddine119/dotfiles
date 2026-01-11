-- ========================================================================== --
--  PLUGIN: NOICE.NVIM
--  Replaces the UI for messages, cmdline and the popupmenu.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/folke/noice.nvim",
	"https://github.com/MunifTanjim/nui.nvim", -- Required dependency
})

-- 2. GUARD
local status, noice = pcall(require, "noice")
if not status then
	return
end

-- 3. CONFIGURE
noice.setup({
	-- UI PRESETS
	presets = {
		bottom_search = true, -- Use a classic bottom cmdline for search
		command_palette = true, -- Position the cmdline and popupmenu together
		long_message_to_split = true, -- Send long messages (like :ls) to a split
		inc_rename = false, -- Enables an input dialog for inc-rename.nvim
		lsp_doc_border = true, -- Add a border to hover docs and signature help
	},

	-- CMDLINE CONFIGURATION
	-- Noice draws the box, Blink handles the completion list inside it.
	cmdline = {
		enabled = true,
		view = "cmdline_popup",
		format = {
			cmdline = { pattern = "^:", icon = "", lang = "vim" },
			search_down = {
				kind = "search",
				pattern = "^/",
				icon = " ",
				lang = "regex",
			},
			search_up = {
				kind = "search",
				pattern = "^%?",
				icon = " ",
				lang = "regex",
			},
		},
	},

	-- NOTIFICATIONS -> DISABLED
	-- We disable this because you are using 'snacks.notifier'
	notify = {
		enabled = false,
		view = "notify",
	},

	-- MESSAGES -> ENABLED
	-- This handles command output like :ls, :messages, print("hello")
	messages = {
		enabled = true,
		view = "notify",
		view_error = "notify",
		view_warn = "notify",
		view_history = "messages",
		view_search = "virtualtext",
	},

	-- LSP INTEGRATION
	lsp = {
		-- Override markdown rendering so that cmp/blink and other plugins use Treesitter
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
		-- Hover & Signature Help (Modern floating windows)
		hover = { enabled = true },
		signature = { enabled = true },

		-- PROGRESS -> DISABLED
		-- We disable this because you are using 'fidget.nvim'
		progress = { enabled = false },
	},

	-- ROUTES (Filter messages)
	routes = {
		-- Example: Skip "written" messages (redundant)
		{
			filter = { event = "msg_show", kind = "", find = "written" },
			opts = { skip = true },
		},
	},
})

-- 4. KEYMAPS
-- History and Dismiss
-- History and Dismiss (Aligned with Snacks keymaps, or use Snacks instead)
vim.keymap.set("n", "<leader>nh", function()
	require("noice").cmd("history")
end, { desc = "[N]otification [H]istory" })

vim.keymap.set("n", "<leader>nd", function()
	require("noice").cmd("dismiss")
end, { desc = "[N]otification [D]ismiss" })

-- Redirect Cmdline (Shift+Enter in command mode redirects output to a split)
vim.keymap.set("c", "<S-Enter>", function()
	require("noice").redirect(vim.fn.getcmdline())
end, { desc = "Redirect Cmdline" })
