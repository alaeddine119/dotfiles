-- ========================================================================== --
--  PLUGIN: GITHUB COPILOT
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/github/copilot.vim",
})

-- 2. CONFIGURATION
-- We use a dedicated variable to track the toggle state locally
local copilot_active = false

-- Disable by default on startup
vim.g.copilot_enabled = false
-- Stop Copilot from stealing <Tab>
vim.g.copilot_no_tab_map = true

-- 3. THE TOGGLE FUNCTION
vim.keymap.set("n", "<leader>tc", function()
	if copilot_active then
		vim.cmd("Copilot disable")
		copilot_active = false
		vim.notify(
			"Copilot OFF",
			vim.log.levels.WARN,
			{ title = "AI Assistant" }
		)
	else
		vim.cmd("Copilot enable")
		copilot_active = true
		vim.notify(
			"Copilot ON",
			vim.log.levels.INFO,
			{ title = "AI Assistant" }
		)
	end
end, { desc = "[T]oggle [C]opilot" })

-- 4. KEYMAPS
vim.g.copilot_no_tab_map = true
vim.keymap.set("i", "<M-y>", 'copilot#Accept("<CR>")', {
	expr = true,
	replace_keycodes = false,
})

-- Partial Accept
vim.keymap.set(
	"i",
	"<M-w>",
	"<Plug>(copilot-accept-word)",
	{ desc = "Accept Word" }
)
vim.keymap.set(
	"i",
	"<M-f>",
	"<Plug>(copilot-accept-line)",
	{ desc = "Accept Line" }
)

-- Navigation (Cycle through options)
-- Alt + ] for Next, Alt + [ for Previous
vim.keymap.set(
	"i",
	"<M-]>",
	"<Plug>(copilot-next)",
	{ desc = "Next Suggestion" }
)
vim.keymap.set(
	"i",
	"<M-[>",
	"<Plug>(copilot-previous)",
	{ desc = "Prev Suggestion" }
)

-- Dismiss/Clear: Alt + c (or standard Ctrl + ])
vim.keymap.set(
	"i",
	"<M-c>",
	"<Plug>(copilot-dismiss)",
	{ desc = "Dismiss Suggestion" }
)

-- Force Suggest: Alt + s (Manually trigger AI even if it's quiet)
vim.keymap.set(
	"i",
	"<M-s>",
	"<Plug>(copilot-suggest)",
	{ desc = "Trigger Suggestion" }
)

vim.keymap.set(
	"n",
	"<leader>gc",
	":Copilot panel<CR>",
	{ desc = "Open Copilot Panel" }
)
