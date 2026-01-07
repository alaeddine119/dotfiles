-- ========================================================================== --
--  PLUGIN: NVIM-AUTOPAIRS
--  Automatically closes brackets, quotes, etc.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
    'https://github.com/windwp/nvim-autopairs',
})

-- 2. GUARD
local status, npairs = pcall(require, "nvim-autopairs")
if not status then return end

-- 3. CONFIGURE
npairs.setup({
    check_ts = true, -- Enable Treesitter integration (smart quoting in Lua/HTML)
    ts_config = {
        lua = { "string", "source" },
        javascript = { "template_string" },
        java = false,
    },
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
    fast_wrap = {
        map = '<M-e>', -- Alt+e to jump around pairs
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = '$',
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        check_comma = true,
        highlight = 'Search',
        highlight_grey = 'Comment'
    },
})
