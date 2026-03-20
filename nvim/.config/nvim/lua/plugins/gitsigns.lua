-- ========================================================================== --
--  PLUGIN: GITSIGNS
--  Git integration for buffers (signs, diffs, blame).
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/lewis6991/gitsigns.nvim",
})

-- 2. GUARD
local status, gitsigns = pcall(require, "gitsigns")
if not status then
	return
end

-- 3. CONFIGURE
gitsigns.setup({
	-- Attach keymaps when gitsigns attaches to a buffer
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns
		local function map(m, l, r, d)
			vim.keymap.set(m, l, r, { buffer = bufnr, desc = d })
		end

		-- Navigation (Standard Motions)
		map("n", "]c", function()
			gs.nav_hunk("next")
		end, "Next Hunk")
		map("n", "[c", function()
			gs.nav_hunk("prev")
		end, "Prev Hunk")

		-- Actions (Normal)
		local n_actions = {
			{ "<leader>hs", gs.stage_hunk, "Stage" },
			{ "<leader>hr", gs.reset_hunk, "Reset" },
			{ "<leader>hp", gs.preview_hunk, "Preview" },
			{ "<leader>hb", gs.blame_line, "Blame" },
			{ "<leader>hd", gs.diffthis, "Diff Index" },
			{ "<leader>hR", gs.reset_buffer, "Reset Buffer" },
		}
		for _, a in ipairs(n_actions) do
			map("n", a[1], a[2], a[3])
		end

		-- Toggles
		map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle Blame")
		map("n", "<leader>tD", gs.toggle_deleted, "Toggle Deleted")
	end,
})
