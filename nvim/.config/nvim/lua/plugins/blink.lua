-- ========================================================================== --
--  PLUGIN: BLINK.CMP
--  High-performance autocompletion engine.
-- ========================================================================== --

-- 1. INSTALL
--    Using vim.pack.add to manage the plugin.
vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		-- Pinned version is safer for stability, but optional.
		-- version = 'v0.*'
	},
	"https://github.com/rafamadriz/friendly-snippets",
})

-- 2. SELF-HEALING BUILD SCRIPT
--    This block checks if the Rust binary is missing and builds it automatically.
--    This fixes the "No fuzzy matching library" error on new installs/config reloads.
local function bootstrap_blink()
	-- The path where vim.pack stores plugins (from your pwd output)
	local blink_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/blink.cmp"
	local binary_path = blink_path .. "/target/release/libblink_cmp_fuzzy.so"

	-- Verify the plugin exists but the binary is missing
	if vim.fn.isdirectory(blink_path) == 1 and vim.fn.filereadable(binary_path) == 0 then
		print("🚧 [Blink] Binary missing. Building from source (may take 1 min)...")

		-- Run cargo build synchronously (blocks UI so we don't crash)
		local obj = vim.system({ "cargo", "build", "--release" }, { cwd = blink_path }):wait()

		if obj.code == 0 then
			print("✅ [Blink] Build Successful! Loading plugin...")
		else
			-- If build fails, print error but let Neovim continue
			print("❌ [Blink] Build Failed. Check :messages for details.")
			vim.notify(obj.stderr, vim.log.levels.ERROR)
		end
	end
end

-- Run the bootstrap check immediately
bootstrap_blink()

-- 3. GUARD
local status, blink = pcall(require, "blink.cmp")
if not status then
	return
end

-- 4. CONFIGURE
blink.setup({
	keymap = {
		preset = "none",
		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "hide" },
		-- Note: We DON'T map <Tab> or <CR> here because Mini.keymap does it
	},

	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},
	completion = {
		-- 1. Disable the menu popping up automatically
		menu = { auto_show = false },

		-- 2. (Optional) Disable "Ghost Text" (the grey text preview)
		--    If you find suggestions irrelevant, this usually gets annoying too.
		ghost_text = { enabled = false },

		-- Keep your documentation settings
		documentation = { auto_show = true, auto_show_delay_ms = 500 },
		-- Blink handles the "integration" part natively.
		-- When you accept a function, Blink adds the ().
		-- When you just type (, nvim-autopairs adds the ).
		accept = {
			auto_brackets = { enabled = true },
		},
	},

	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},

    cmdline = {
        sources = function()
            local type = vim.fn.getcmdtype()
            -- Search mode (/ or ?) -> use buffer words
            if type == '/' or type == '?' then return { 'buffer' } end
            -- Command mode (:) -> use cmdline history and commands
            if type == ':' then return { 'cmdline' } end
            return {}
        end
    },

	signature = { enabled = true },

	-- Force it to use the binary we just built
	fuzzy = { implementation = "prefer_rust_with_warning" },
})
