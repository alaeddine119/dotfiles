-- ========================================================================== --
--  PLUGIN: MINI.NVIM
--  A library of 40+ modules. We install the whole library, but only
--  load the modules we actually want to use.
-- ========================================================================== --

-- 1. INSTALL
--    We install the main library. This gives access to ALL mini modules.
vim.pack.add({
	"https://github.com/echasnovski/mini.nvim",
	-- Recommended: Install 'stable' branch for stability, or remove for 'main'
	-- branch: 'stable'
})

-- 2. UTILITIES (Non-conflicting improvements)
--    These can be enabled immediately without breaking your current setup.

-- Better text objects (e.g., va) for arguments, va? for user prompts)
-- Highly recommended to keep this!
require("mini.ai").setup({ n_lines = 500 })

-- Fast surrounding (sa, sd, sr) - Alternative to tpope/vim-surround
require("mini.surround").setup()

--    Extends f/t to work on multiple lines.
require("mini.jump").setup()

-- Split and join arguments (gS)
require("mini.splitjoin").setup()

-- Highlight word under cursor
require("mini.cursorword").setup()

-- Align text (ga) - Great for formatting tables or assignments
require("mini.align").setup()

-- Move lines/selections (Alt+hjkl)
require("mini.move").setup({
	mappings = {
		-- Move visual selection in Visual mode.
		left = "<M-h>",
		right = "<M-l>",
		down = "<M-j>",
		up = "<M-k>",
		-- Move current line in Normal mode
		line_left = "<M-h>",
		line_right = "<M-l>",
		line_down = "<M-j>",
		line_up = "<M-k>",
	},
})

-- Visualizes the scope of the current indent (similar to indent-blankline)
require("mini.indentscope").setup({
	symbol = "│",
	options = { try_as_border = true },
})

-- Simple and fast icons (replaces nvim-web-devicons mostly)
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons() -- Let other plugins use MiniIcons

-- Smooth scrolling and cursor movement.
require("mini.animate").setup({
	-- Disable Scroll animation to fix touchpad lag
	scroll = { enable = false },

	-- Keep Cursor animation (smooth movement within buffer)
	cursor = {
		enable = true,
		timing = require("mini.animate").gen_timing.linear({
			duration = 100,
			unit = "total",
		}),
	},

	-- Enable Resize/Open/Close animations if you like them
	resize = { enable = true },
	open = { enable = true },
	close = { enable = true },
})

-- Highlight trailing whitespace (red blocks at end of line)
require("mini.trailspace").setup()

-- ========================================================================== --
--  3. REPLACEMENTS (Comment out your old plugins if you enable these)
-- ========================================================================== --

-- REPLACES: autopairs.lua
require("mini.pairs").setup()

-- REPLACES: comment.lua
require("mini.comment").setup()

-- REPLACES: which-key.lua
local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		-- Leader triggers
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },

		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },

		-- g key (LSP, Go to...)
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },

		-- Marks & Registers
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },

		-- Window commands
		{ mode = "n", keys = "<C-w>" },

		-- Folds
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
	},

	clues = {
		-- 1. BUILT-IN ENHANCEMENTS
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),

		-- 2. CUSTOM LEADER GROUPS
		-- <Leader>b: Buffer management (Delete, Scratch...)
		{ mode = "n", keys = "<Leader>b", desc = "+[B]uffers" },

		-- <Leader>c: Code actions (Format, Rename...)
		{ mode = "n", keys = "<Leader>c", desc = "+[C]ode Actions" },

		-- <Leader>g: Git main commands (Lazygit, Browse)
		{ mode = "n", keys = "<Leader>g", desc = "+[G]it Tools" },

		-- <Leader>h: Git Hunks (Stage, Reset, Preview via Gitsigns)
		{ mode = "n", keys = "<Leader>h", desc = "+Git [H]unks" },

		-- <Leader>n: Notifications (History, Dismiss)
		{ mode = "n", keys = "<Leader>n", desc = "+[N]otifications" },

		-- <Leader>s: Search (Telescope Files, Grep, Config...)
		{ mode = "n", keys = "<Leader>s", desc = "+[S]earch" },

		-- <Leader>t: Toggles (Spell, Wrap, Diagnostics, Dim...)
		{ mode = "n", keys = "<Leader>t", desc = "+[T]oggles" },

		-- <Leader>x: Trouble (Diagnostics, Quickfix...)
		{ mode = "n", keys = "<Leader>x", desc = "+Diagnostics [X]" },

		-- 3. SPECIFIC MAPPINGS
		-- Helper clues for standalone keys that don't belong to a group
		{ mode = "n", keys = "<Leader>w", desc = "[W]rite File" },
		{ mode = "n", keys = "<Leader>q", desc = "[Q]uit" },
		{ mode = "n", keys = "<Leader>z", desc = "[Z]en Mode" },
		{ mode = "n", keys = "<Leader>U", desc = "[U]ndoTree" },
		{ mode = "n", keys = "<Leader>a", desc = "Harpoon [A]dd" },
		{ mode = "n", keys = "<Leader>e", desc = "Harpoon [E]dit" },
	},

	window = {
		config = { width = "auto" },
		-- Slight delay prevents the popup from flashing if you type fast
		delay = 300,
	},
})

-- REPLACES: telescope.lua (Partial replacement, Pick is lighter/faster)
-- require('mini.pick').setup()

-- REPLACES: oil.lua (Files is a column view explorer)
-- require('mini.files').setup()

-- REPLACES: gitsigns.lua (Diff is simpler, Gitsigns is more robust)
-- require('mini.diff').setup()
-- require('mini.git').setup()

-- REPLACES: lualine.lua
require("mini.statusline").setup()

-- REPLACES: todo-comments.lua (Hipatterns can do highlighing)
require("mini.hipatterns").setup({
	highlighters = {
		fixme = {
			pattern = "%f[%w]()FIXME()%f[%W]",
			group = "MiniHipatternsFixme",
		},
		hack = {
			pattern = "%f[%w]()HACK()%f[%W]",
			group = "MiniHipatternsHack",
		},
		todo = {
			pattern = "%f[%w]()TODO()%f[%W]",
			group = "MiniHipatternsTodo",
		},
		note = {
			pattern = "%f[%w]()NOTE()%f[%W]",
			group = "MiniHipatternsNote",
		},
		hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
	},
})

-- Helper function for expression mappings
local function map_blink(lhs, rhs)
	vim.keymap.set(
		"i",
		lhs,
		rhs,
		{ expr = true, silent = true, replace_keycodes = true }
	)
end

-- Ctrl+N: Select Next (Navigation)
map_blink("<C-n>", function()
	local blink = require("blink.cmp")
	if blink.is_menu_visible() then
		return blink.select_next()
	end
	return "<C-n>"
end)

-- Ctrl+P: Select Previous (Navigation)
map_blink("<C-p>", function()
	local blink = require("blink.cmp")
	if blink.is_menu_visible() then
		return blink.select_prev()
	end
	return "<C-p>"
end)

-- Ctrl+Y: Accept Completion (Yes)
map_blink("<C-y>", function()
	local blink = require("blink.cmp")
	if blink.is_menu_visible() then
		return blink.accept()
	end
	return "<C-y>"
end)

-- Ctrl+E: Cancel / Close Menu (Exit)
map_blink("<C-e>", function()
	local blink = require("blink.cmp")
	if blink.is_menu_visible() then
		return blink.hide()
	end
	return "<C-e>"
end)

-- ========================================================================== --
--  5. EXTRAS
-- ========================================================================== --

-- BETTER ESCAPE (JK to Exit)
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Trim trailing whitespace manually
vim.keymap.set("n", "<leader>tw", function()
	require("mini.trailspace").trim()
end, { desc = "Trim Whitespace" })
