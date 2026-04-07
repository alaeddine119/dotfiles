-- ========================================================================== --
--  PLUGIN: MINI.NVIM
-- ========================================================================== --

vim.pack.add({ "https://github.com/echasnovski/mini.nvim" })

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

vim.schedule(function()
	require("mini.trailspace").setup()
end)

require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
require("mini.indentscope").setup()

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

			return statusline.combine_groups({
				{ hl = mode_hl, strings = { mode } },
				{ hl = "MiniStatuslineDevinfo", strings = { git, diag } },
				"%<",
				{ hl = "MiniStatuslineFilename", strings = { filename } },
				"%=",
				{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
				{ hl = mode_hl, strings = { location } },
			})
		end,
	},
})

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

local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		{ mode = { "n", "x" }, keys = "<Leader>" },
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
		{ mode = "i", keys = "<C-x>" },
		{ mode = { "n", "x" }, keys = "g" },
		{ mode = { "n", "x" }, keys = "'" },
		{ mode = { "n", "x" }, keys = "`" },
		{ mode = { "n", "x" }, keys = '"' },
		{ mode = { "i", "c" }, keys = "<C-r>" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = { "n", "x" }, keys = "z" },
	},
	clues = {
		miniclue.gen_clues.square_brackets(),
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
		{ mode = "n", keys = "<Leader>b", desc = "+Buffers" },
		{ mode = "n", keys = "<Leader>c", desc = "+Code" },
		{ mode = "n", keys = "<Leader>g", desc = "+Git" },
		{ mode = "n", keys = "<leader>n", desc = "+Notifications" },
		{ mode = "n", keys = "<Leader>s", desc = "+Search" },
		{ mode = "n", keys = "<Leader>t", desc = "+Toggles" },
		{ mode = "n", keys = "<Leader>x", desc = "+Trouble" },
	},
	window = { delay = 300 },
})
