-- ========================================================================== --
--  PLUGIN: MINI.NVIM
--  A library of 40+ modules. We install the whole library, but only
--  load the modules we actually want to use.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({ "https://github.com/echasnovski/mini.nvim" })

-- 2. SIMPLE MODULES (Default setups)
local modules = {
	"ai",
	"surround",
	"jump",
	"splitjoin",
	"cursorword",
	"align",
	"move",
	"pairs",
	"comment",
}
for _, mod in ipairs(modules) do
	require("mini." .. mod).setup()
end

-- Delay trailspace so it doesn't paint the Snacks dashboard pink!
vim.schedule(function()
	require("mini.trailspace").setup()
end)

-- 3. UI ENHANCEMENTS
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

require("mini.indentscope").setup({ symbol = "│" })

require("mini.animate").setup({
	scroll = { enable = false },
	cursor = { enable = false },
	resize = {
		timing = require("mini.animate").gen_timing.linear({
			duration = 50,
			unit = "total",
		}),
	},
	open = {
		timing = require("mini.animate").gen_timing.linear({
			duration = 50,
			unit = "total",
		}),
	},
	close = {
		timing = require("mini.animate").gen_timing.linear({
			duration = 50,
			unit = "total",
		}),
	},
})

-- 4. MINI.CLUE (Which-Key Alternative)
local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		-- Leader triggers
		{ mode = { "n", "x" }, keys = "<Leader>" },
		-- `[` and `]` keys (Next/Prev)
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },
		-- `g` key (LSP / Goto)
		{ mode = { "n", "x" }, keys = "g" },
		-- Marks & Registers
		{ mode = { "n", "x" }, keys = "'" },
		{ mode = { "n", "x" }, keys = "`" },
		{ mode = { "n", "x" }, keys = '"' },
		{ mode = { "i", "c" }, keys = "<C-r>" },
		-- Window commands
		{ mode = "n", keys = "<C-w>" },
		-- Folds & Spelling
		{ mode = { "n", "x" }, keys = "z" },
	},

	clues = {
		-- Native Neovim Clues
		miniclue.gen_clues.square_brackets(),
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),

		-- Custom <Leader> Prefix Descriptions
		{ mode = "n", keys = "<Leader>b", desc = "+Buffers" },
		{ mode = "n", keys = "<Leader>c", desc = "+Code" },
		{ mode = "n", keys = "<Leader>d", desc = "+Debug" },
		{ mode = "n", keys = "<Leader>g", desc = "+Git" },
		{ mode = "n", keys = "<Leader>h", desc = "+Hunks" },
		{ mode = "n", keys = "<leader>p", desc = "+Packages" },
		{ mode = "n", keys = "<Leader>r", desc = "+Run" },
		{ mode = "n", keys = "<Leader>s", desc = "+Search" },
		{ mode = "n", keys = "<Leader>t", desc = "+Toggles" },
		{ mode = "n", keys = "<Leader>x", desc = "+Trouble" },
	},
	window = {
		config = { width = "auto" },
		delay = 300,
	},
})

-- 5. STATUSLINE (With Copilot integration)
require("mini.statusline").setup({
	content = {
		active = function()
			local statusline = require("mini.statusline")
			local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
			local git = statusline.section_git({ trunc_width = 75 })
			local diag = statusline.section_diagnostics({ trunc_width = 75 })
			local filename = statusline.section_filename({ trunc_width = 140 })
			local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
			local location = statusline.section_location({ trunc_width = 75 })
			local ai = (
				vim.fn.exists("*copilot#Enabled") == 1
				and vim.fn["copilot#Enabled"]() == 1
			)
					and " "
				or ""

			return statusline.combine_groups({
				{ hl = mode_hl, strings = { mode } },
				{ hl = "MiniStatuslineDevinfo", strings = { git, diag, ai } },
				"%<",
				{ hl = "MiniStatuslineFilename", strings = { filename } },
				"%=",
				{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
				{ hl = mode_hl, strings = { location } },
			})
		end,
	},
})

-- 6. HIPATTERNS (TODO/FIXME Highlighting)
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
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
		hex_color = hipatterns.gen_highlighter.hex_color(),
	},
})

-- 7. EXTRAS
vim.keymap.set("n", "<leader>tw", function()
	require("mini.trailspace").trim()
end, { desc = "[T]rim [W]hitespace" })
