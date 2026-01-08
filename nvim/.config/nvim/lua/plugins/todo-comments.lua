-- ========================================================================== --
--  PLUGIN: TODO COMMENTS
--  Highlight and search for TODO, HACK, BUG tags in comments.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/nvim-lua/plenary.nvim", -- Required dependency
})

-- 2. GUARD
local status, todo = pcall(require, "todo-comments")
if not status then
	return
end

-- 3. CONFIGURE
todo.setup({
	signs = true, -- Show icons in the sign column
	keywords = {
		FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
		TODO = { icon = " ", color = "info" },
		HACK = { icon = " ", color = "warning" },
		WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
		PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
		NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
	},
	highlight = {
		multiline = true, -- Enable multiline todo comments
		keyword = "bg", -- "fg", "bg", "wide" (wide highlight)
	},
})

-- 4. KEYMAPS

-- Jump between tags
vim.keymap.set("n", "]t", function()
	todo.jump_next()
end, { desc = "Next TODO tag" })
vim.keymap.set("n", "[t", function()
	todo.jump_prev()
end, { desc = "Previous TODO tag" })

-- Integration: Telescope (Search all todos in project)
vim.keymap.set("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "[S]earch [T]odos" })

-- Integration: Trouble (List all todos in side panel)
-- We toggle the "todo" mode in Trouble
vim.keymap.set("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Trouble: Todos" })
