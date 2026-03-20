-- ========================================================================== --
--  PLUGIN: NVIM-SCROLLBAR
--  Adds a VS Code-style scrollbar with diagnostics, git signs, and search marks.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/petertriho/nvim-scrollbar",
	"https://github.com/kevinhwang91/nvim-hlslens",
})

-- 2. GUARD
local ok, sb = pcall(require, "scrollbar")
if not ok then
	return
end

-- 3. CONFIGURE
local p = require("rose-pine.palette")
sb.setup({
	show_in_active_only = true,
	handle = { text = " ", blend = 30, color = p.rose },
	marks = {
		Search = { color = p.gold },
		Error = { color = p.love },
		Warn = { color = p.gold },
		Info = { color = p.foam },
		Hint = { color = p.iris },
		Misc = { color = p.subtle },
		GitAdd = { color = p.foam },
		GitChange = { color = p.rose },
		GitDelete = { color = p.love },
	},
	excluded_filetypes = { "TelescopePrompt", "noice", "oil", "alpha" },
})

-- 4. HLSLENS (Search Integration)
local ok_h, hl = pcall(require, "hlslens")
if ok_h then
	hl.setup({
		build_position_cb = function(plist)
			require("scrollbar.handlers.search").handler.show(plist.start_pos)
		end,
	})
	vim.api.nvim_create_autocmd("CmdlineLeave", {
		callback = function()
			require("scrollbar.handlers.search").handler.hide()
		end,
	})
end
