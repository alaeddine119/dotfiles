-- ========================================================================== --
--  PLUGIN: NVIM-LINT
--  An asynchronous linter plugin (complementary to LSP).
-- ========================================================================== --

-- 1. Install
vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })

-- 2. Guard
local status, lint = pcall(require, "lint")
if not status then
	return
end

lint.linters_by_ft = {
	html = { "htmlhint" },
	css = { "stylelint" },
}

-- 5. Auto-Trigger
vim.api.nvim_create_autocmd(
	{ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" },
	{
		group = vim.api.nvim_create_augroup("lint", { clear = true }),
		callback = function()
			lint.try_lint()
		end,
	}
)
