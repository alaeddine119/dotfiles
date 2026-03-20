-- ========================================================================== --
--  PLUGIN: GITHUB COPILOT (Native Lazy-Load)
-- ========================================================================== --

-- 1. INSTALL (Dormant State)
vim.pack.add({
	{ src = "https://github.com/github/copilot.vim", name = "copilot" },
}, { load = false })

-- 2. CONFIGURATION
vim.g.copilot_enabled = false
vim.g.copilot_no_tab_map = true

local copilot_initialized = false
local map = vim.keymap.set

-- 3. THE TOGGLE & LOAD FUNCTION
map("n", "<leader>tc", function()
	if not copilot_initialized then
		vim.cmd("packadd copilot")

		-- Map Insert-mode keys ONLY after loading
		map(
			"i",
			"<M-y>",
			'copilot#Accept("<CR>")',
			{ expr = true, replace_keycodes = false }
		)
		map(
			"i",
			"<M-w>",
			"<Plug>(copilot-accept-word)",
			{ desc = "Accept Word" }
		)
		map(
			"i",
			"<M-f>",
			"<Plug>(copilot-accept-line)",
			{ desc = "Accept Line" }
		)
		map("i", "<M-]>", "<Plug>(copilot-next)", { desc = "Next Suggestion" })
		map(
			"i",
			"<M-[>",
			"<Plug>(copilot-previous)",
			{ desc = "Prev Suggestion" }
		)
		map(
			"i",
			"<M-c>",
			"<Plug>(copilot-dismiss)",
			{ desc = "Dismiss Suggestion" }
		)
		map(
			"i",
			"<M-s>",
			"<Plug>(copilot-suggest)",
			{ desc = "Trigger Suggestion" }
		)

		copilot_initialized = true
	end

	if vim.g.copilot_enabled == 1 then
		vim.cmd("Copilot disable")
		vim.notify(
			"Copilot OFF",
			vim.log.levels.WARN,
			{ title = "AI Assistant" }
		)
	else
		vim.cmd("Copilot enable")
		vim.notify(
			"Copilot ON",
			vim.log.levels.INFO,
			{ title = "AI Assistant" }
		)
	end
end, { desc = "[T]oggle [C]opilot" })

-- 4. UTILITY
map("n", "<leader>gc", function()
	if not copilot_initialized then
		vim.notify("Load Copilot first with <leader>tc", vim.log.levels.ERROR)
	else
		vim.cmd("Copilot panel")
	end
end, { desc = "Open Copilot Panel" })
