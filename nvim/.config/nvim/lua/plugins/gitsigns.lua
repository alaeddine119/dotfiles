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
			{ "<leader>hs", gs.stage_hunk, "[S]tage" },
			{ "<leader>hr", gs.reset_hunk, "[R]eset" },
			{ "<leader>hp", gs.preview_hunk, "[P]review" },
			{ "<leader>hb", gs.blame_line, "[B]lame" },
			{ "<leader>hd", gs.diffthis, "[D]iff Index" },
			{ "<leader>hR", gs.reset_buffer, "[^R]eset Buffer" },
		}
		for _, a in ipairs(n_actions) do
			map("n", a[1], a[2], a[3])
		end

		-- Toggles
		map("n", "<leader>tb", gs.toggle_current_line_blame, "[B]lame")
		map("n", "<leader>tD", gs.toggle_deleted, "[^D]eleted")
	end,
})
