local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false)

for _, line in ipairs(lines) do
	if line:match("[\216-\219][\128-\191]") then
		vim.opt_local.arabic = true
		vim.opt_local.spelllang = "ar,en"

		break
	end
end
