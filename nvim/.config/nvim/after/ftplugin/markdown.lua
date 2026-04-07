-- ~/.config/nvim/ftplugin/markdown.lua
local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false)

for _, line in ipairs(lines) do
	if line:match("[\216-\219][\128-\191]") then
		vim.opt_local.arabic = true
		vim.opt_local.spelllang = "ar,en"

		break
	end
end
-- Helper function to convert any string into a clean filename slug
local function slugify(str)
	local s = str:lower()
	-- 1. Remove backslashes (merges LaTeX commands like \nabla into nabla)
	s = s:gsub("\\", "")
	-- 2. Replace spaces and dashes with underscores
	s = s:gsub("[%s%-]+", "_")
	-- 3. Strip everything else that isn't alphanumeric or an underscore
	s = s:gsub("[^%w_]", "")
	return s
end
vim.keymap.set("n", "gf", function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	local start_md, end_md, md_link = line:find("%[[^%]]+%]%(([^%)]+)%)")
	if start_md and col >= start_md - 1 and col <= end_md then
		local raw_name = md_link:gsub("%.md$", "")
		local filename = slugify(raw_name) .. ".md"
		vim.cmd("edit " .. vim.fn.fnameescape(filename))
		return
	end
end, { buffer = true, desc = "Follow or Create Markdown Link" })
