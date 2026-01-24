-- ========================================================================== --
--  PLUGIN: NVIM-SCROLLBAR
--  Adds a VS Code-style scrollbar with diagnostics, git signs, and search marks.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/petertriho/nvim-scrollbar",
	-- Optional: nvim-hlslens makes search results appear in the scrollbar
	"https://github.com/kevinhwang91/nvim-hlslens",
})

-- 2. GUARD
local status, scrollbar = pcall(require, "scrollbar")
if not status then
	return
end

-- 3. COLORS & HIGHLIGHTS (Rose Pine Integration)
--    We define a specific handle color to ensure it's visible but subtle against the Rose Pine background.
local palette = require("rose-pine.palette")
local colors = {
	handle = palette.pine, -- Subtle highlight for the bar itself
	search = palette.gold, -- Gold for search results
	error = palette.love, -- Red for errors
	warn = palette.gold, -- Yellow for warnings
	info = palette.foam, -- Blue/Cyan for info
	hint = palette.iris, -- Purple for hints
	git_add = palette.foam, -- Git Add
	git_change = palette.rose, -- Git Change
	git_delete = palette.love, -- Git Delete
}

-- 4. CONFIGURE
scrollbar.setup({
	show = true,
	show_in_active_only = true, -- Only show in the focused window
	set_highlights = true,
	folds = 1000, -- Handle folds

	-- Visual Configuration
	handle = {
		text = " ",
		blend = 30, -- Transparency (0-100)
		color = colors.handle,
		hide_if_all_visible = true,
	},

	-- Markers Configuration
	marks = {
		Search = { color = colors.search },
		Error = { color = colors.error },
		Warn = { color = colors.warn },
		Info = { color = colors.info },
		Hint = { color = colors.hint },
		Misc = { color = palette.subtle },
		GitAdd = { color = colors.git_add },
		GitChange = { color = colors.git_change },
		GitDelete = { color = colors.git_delete },
	},

	-- Handlers (What shows up in the bar)
	handlers = {
		cursor = true,
		diagnostic = true, -- Shows your LSP errors
		gitsigns = true, -- Shows your Git changes (requires gitsigns.lua)
		handle = true,
		search = true, -- Requires nvim-hlslens
	},

	-- Exclude filetypes that don't need a scrollbar
	excluded_filetypes = {
		"prompt",
		"TelescopePrompt",
		"noice",
		"oil",
		"netrw",
		"alpha",
	},
})

-- 5. SEARCH INTEGRATION (HLSLENS)
--    This allows the scrollbar to show search result positions
local hlslens_status, hlslens = pcall(require, "hlslens")
if hlslens_status then
	hlslens.setup({
		-- This function syncs the search results with the scrollbar
		build_position_cb = function(plist, _, _, _)
			require("scrollbar.handlers.search").handler.show(plist.start_pos)
		end,
	})

	-- Auto-hide scrollbar search marks when you clear search (CmdlineLeave)
	vim.cmd([[
        augroup scrollbar_search_hide
            autocmd!
            autocmd CmdlineLeave : lua require('scrollbar.handlers.search').handler.hide()
        augroup END
    ]])
end
