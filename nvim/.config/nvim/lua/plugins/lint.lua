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

-- 3. Custom Linter Logic (MISS_HIT via UV)
local mh_parser = function(output, _)
	if not output or output == "" then
		return {}
	end
	local ok, decoded = pcall(vim.json.decode, output)
	if not ok then
		return {}
	end

	local diagnostics = {}
	for _, file in ipairs(decoded or {}) do
		for _, issue in ipairs(file.issues or {}) do
			table.insert(diagnostics, {
				lnum = (issue.line or 1) - 1,
				col = (issue.col or 1) - 1,
				end_lnum = (issue.line or 1) - 1,
				end_col = (issue.col or 1) + 1,
				severity = vim.diagnostic.severity.WARN,
				message = string.format(
					"[%s] %s",
					issue.rule or "lint",
					(issue.message or ""):gsub("%z", "<NUL>")
				),
				source = "miss_hit",
			})
		end
	end
	return diagnostics
end

local mh_args = { "-q", "tool", "run", "--from", "miss_hit" }
lint.linters.mh_lint = {
	name = "mh_lint",
	cmd = "uv",
	args = vim.list_extend(
		{ "mh_lint", "--json", "--input-encoding", "iso-8859-1" },
		mh_args
	),
	stdin = false,
	parser = mh_parser,
	stream = "stdout",
	ignore_exitcode = true,
}
lint.linters.mh_metric = {
	name = "mh_metric",
	cmd = "uv",
	args = vim.list_extend(
		{ "mh_metric", "--json", "--input-encoding", "iso-8859-1" },
		mh_args
	),
	stdin = false,
	parser = mh_parser,
	stream = "stdout",
	ignore_exitcode = true,
}

-- 4. Configure Linters
lint.linters_by_ft = {
	matlab = { "mh_lint", "mh_metric" },
	dockerfile = { "hadolint" },
	css = { "stylelint" },
	html = { "htmlhint" },
	gitcommit = { "commitlint" },
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
