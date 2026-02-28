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

-- ========================================================================== --
--  3. CUSTOM LINTERS (MISS_HIT via UV)
-- ========================================================================== --

-- Parser: Decodes JSON and Sanitizes Messages (Fixes Blob Error)
local mh_parser = function(output, _)
	if output == "" or output == nil then
		return {}
	end

	-- 1. Try to decode the JSON
	local status_json, decoded = pcall(vim.json.decode, output)
	if not status_json then
		return {}
	end

	local diagnostics = {}
	for _, file_result in ipairs(decoded or {}) do
		for _, issue in ipairs(file_result.issues or {}) do
			-- 2. SANITIZE: Remove Null bytes (%z) which cause Vim:E976 blobs
			local raw_msg = issue.message or ""
			local clean_msg = raw_msg:gsub("%z", "<NUL>")

			table.insert(diagnostics, {
				lnum = (issue.line or 1) - 1,
				col = (issue.col or 1) - 1,
				end_lnum = (issue.line or 1) - 1,
				end_col = (issue.col or 1) + 1,
				severity = vim.diagnostic.severity.WARN,
				message = string.format(
					"[%s] %s",
					issue.rule or "lint",
					clean_msg
				),
				source = "miss_hit",
			})
		end
	end
	return diagnostics
end

-- Define mh_lint (Bugs)
lint.linters.mh_lint = {
	name = "mh_lint",
	cmd = "uv",
	-- FIXED: Use a Table, not a Function.
	-- nvim-lint automatically appends the filename when stdin=false.
	args = {
		"-q",
		"tool",
		"run",
		"--from",
		"miss_hit",
		"mh_lint",
		"--json",
		"--input-encoding",
		"iso-8859-1", -- Handle legacy chars safely
	},
	stdin = false,
	parser = mh_parser,
	stream = "stdout",
	ignore_exitcode = true,
}

-- Define mh_metric (Complexity)
lint.linters.mh_metric = {
	name = "mh_metric",
	cmd = "uv",
	args = {
		"-q",
		"tool",
		"run",
		"--from",
		"miss_hit",
		"mh_metric",
		"--json",
		"--input-encoding",
		"iso-8859-1",
	},
	stdin = false,
	parser = mh_parser,
	stream = "stdout",
	ignore_exitcode = true,
}

-- 4. Configure Linters
--    Map filetypes to the specific linter tools.
lint.linters_by_ft = {
	-- MATLAB (Using our custom definitions)
	matlab = { "mh_lint", "mh_metric" },

	-- DevOps
	dockerfile = { "hadolint" },

	-- Web
	-- HTML/CSS LSPs are good, but these catch extra style issues.
	css = { "stylelint" },
	html = { "htmlhint" },

	-- Git
	-- Checks commit messages against standard conventions.
	gitcommit = { "commitlint" },

	-- NOTE: We do NOT add Rust here.
	-- Your "rust-analyzer" LSP already handles linting (cargo check/clippy) perfectly.
}

-- 5. Auto-Trigger Linting
--    Unlike LSP, nvim-lint needs to be triggered manually via events.
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd(
	{ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" },
	{
		group = lint_augroup,
		callback = function()
			-- Try to lint the current buffer
			lint.try_lint()
		end,
	}
)
