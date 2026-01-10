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

--    Replaces standard vim.notify with a nice floating window.
--    Works well alongside 'fidget.nvim' (which handles LSP progress).
local notify = require("mini.notify")
notify.setup({
	-- Critical: Disable LSP progress in mini.notify because
	-- 'fidget.nvim' handles it better (with the spinning circle).
	lsp_progress = { enable = false },
})
vim.notify = notify.make_notify()

--    Smooth scrolling and cursor movement.
require("mini.animate").setup({
	-- Disable Scroll animation to fix touchpad lag
	scroll = { enable = false },

	-- Keep Cursor animation (smooth movement within buffer)
	cursor = {
		enable = true,
		timing = require("mini.animate").gen_timing.linear({ duration = 100, unit = "total" }),
	},

	-- Enable Resize/Open/Close animations if you like them
	resize = { enable = true },
	open = { enable = true },
	close = { enable = true },
})

-- ========================================================================== --
--  3. REPLACEMENTS (Comment out your old plugins if you enable these)
-- ========================================================================== --

-- REPLACES: autopairs.lua
require("mini.pairs").setup()

-- REPLACES: comment.lua
require("mini.comment").setup()

-- REPLACES: which-key.lua
require("mini.clue").setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "i", keys = "<C-x>" },
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
	},
	clues = {
		-- Enhance this by adding descriptions for <Leader> mapping groups
		require("mini.clue").gen_clues.builtin_completion(),
		require("mini.clue").gen_clues.g(),
		require("mini.clue").gen_clues.marks(),
		require("mini.clue").gen_clues.registers(),
		require("mini.clue").gen_clues.windows(),
		require("mini.clue").gen_clues.z(),
	},
	window = {
		config = { width = "auto" },
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
		fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
		hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
		todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
		note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
		hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
	},
})

-- Helper function for expression mappings
local function map_blink(lhs, rhs)
	vim.keymap.set("i", lhs, rhs, { expr = true, silent = true, replace_keycodes = true })
end

-- TAB: Completion Next -> Indent
map_blink("<Tab>", function()
	local blink = require("blink.cmp")
	if blink.is_menu_visible() then
		return blink.select_next()
	end
	return "<Tab>"
end)

-- SHIFT-TAB: Completion Prev -> Dedent
map_blink("<S-Tab>", function()
	local blink = require("blink.cmp")
	if blink.is_menu_visible() then
		return blink.select_prev()
	end
	return "<S-Tab>"
end)

-- ENTER: Accept Completion -> New Line
map_blink("<CR>", function()
	local blink = require("blink.cmp")
	if blink.is_menu_visible() then
		return blink.accept()
	end
	return "<CR>"
end)

-- ========================================================================== --
--  5. EXTRAS
-- ========================================================================== --

-- REPLACES: which-key.lua
-- (Requires manual trigger configuration)
local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		-- Leader triggers
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "i", keys = "<C-x>" }, -- Built-in completion
		{ mode = "n", keys = "g" }, -- `g` key
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "'" }, -- Marks
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },
		{ mode = "n", keys = '"' }, -- Registers
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },
		{ mode = "n", keys = "<C-w>" }, -- Window commands
		{ mode = "n", keys = "z" }, -- Folds
		{ mode = "x", keys = "z" },
	},
	clues = {
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
		-- Custom Descriptions
		{ mode = "n", keys = "<Leader>f", desc = "+Format" },
		{ mode = "n", keys = "<Leader>s", desc = "+Search" },
		{ mode = "n", keys = "<Leader>g", desc = "+Git" },
		{ mode = "n", keys = "<Leader>x", desc = "+Trouble" },
		{ mode = "n", keys = "<Leader>c", desc = "+Code" },
	},
	window = {
		config = { width = "auto" },
	},
})

-- BETTER ESCAPE (JK to Exit)
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
