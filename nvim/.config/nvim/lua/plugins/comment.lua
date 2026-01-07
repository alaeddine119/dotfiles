-- ========================================================================== --
--  PLUGIN: COMMENT.NVIM
--  Smart and powerful commenting plugin.
-- ========================================================================== --

-- 1. Install Plugin & Dependencies
vim.pack.add({
	"https://github.com/numToStr/Comment.nvim",

	-- Recommended: Smarter commenting for mixed files (like HTML/JS, React, Vue)
	"https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
})

-- 2. Guard
local status, comment = pcall(require, "Comment")
if not status then
	return
end

-- 3. Configure Context Commentstring (Dependency)
--    This is required to make the pre_hook work below.
require("ts_context_commentstring").setup({
	enable_autocmd = false,
})

-- 4. Configure Comment.nvim
comment.setup({
	-- Add a space b/w comment and the line
	padding = true,

	-- Whether the cursor should stay at its position
	sticky = true,

	-- Integrate with nvim-ts-context-commentstring
	-- This makes it work perfectly in mixed filetypes (like .jsx, .vue, .html)
	pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),

	-- Keybindings (We keep defaults because they are excellent)
	-- gcc: toggle line comment
	-- gbc: toggle block comment
	-- gc[motion]: comment target (e.g. gcap comments a paragraph)
})
