-- ========================================================================== --
--  PLUGIN: NVIM-LINT
--  An asynchronous linter plugin (complementary to LSP).
--  It catches style errors and bugs that LSPs might miss.
-- ========================================================================== --

-- 1. Install
vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })

-- 2. Guard
local status, lint = pcall(require, "lint")
if not status then
	return
end

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
