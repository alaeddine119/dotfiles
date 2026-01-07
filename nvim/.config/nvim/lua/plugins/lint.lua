-- ========================================================================== --
--  PLUGIN: NVIM-LINT
--  An asynchronous linter plugin (complementary to LSP).
--  It catches style errors and bugs that LSPs might miss.
-- ========================================================================== --

-- 1. Install
vim.pack.add({
	"https://github.com/mfussenegger/nvim-lint",
})

-- 2. Guard
local status, lint = pcall(require, "lint")
if not status then
	return
end

-- 3. Configure Linters
--    Map filetypes to the specific linter tools.
lint.linters_by_ft = {

	-- DevOps
	dockerfile = { "hadolint" },

	-- Web
	-- HTML/CSS LSPs are good, but these catch extra style issues.
	css = { "stylelint" },
	html = { "htmlhint" },

	-- Lua
	-- "luacheck" is great for catching global variable pollution.
	lua = { "luacheck" },

	-- Git
	-- Checks commit messages against standard conventions.
	gitcommit = { "commitlint" },

	-- NOTE: We do NOT add Rust here.
	-- Your "rust-analyzer" LSP already handles linting (cargo check/clippy) perfectly.
}

-- 4. Auto-Trigger Linting
--    Unlike LSP, nvim-lint needs to be triggered manually via events.
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
	group = lint_augroup,
	callback = function()
		-- Try to lint the current buffer
		lint.try_lint()
	end,
})
