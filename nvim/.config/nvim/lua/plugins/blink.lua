-- ========================================================================== --
--  PLUGIN: BLINK.CMP
--  High-performance autocompletion engine.
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		-- version = 'v0.*' -- Keep main branch for latest features
	},
	"https://github.com/rafamadriz/friendly-snippets",
})

-- 2. SELF-HEALING BUILD SCRIPT
local function bootstrap_blink()
	local blink_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/blink.cmp"
	local binary_path = blink_path .. "/target/release/libblink_cmp_fuzzy.so"

	if
		vim.fn.isdirectory(blink_path) == 1
		and vim.fn.filereadable(binary_path) == 0
	then
		print("🚧 [Blink] Binary missing. Building from source...")
		local obj = vim.system(
			{ "cargo", "build", "--release" },
			{ cwd = blink_path }
		)
			:wait()
		if obj.code ~= 0 then
			print("❌ [Blink] Build Failed. Check :messages.")
		end
	end
end
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
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },
		["<C-y>"] = { "select_and_accept" },
		["<CR>"] = { "accept", "fallback" },
	},

	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},

	completion = {
		menu = { auto_show = false },
		ghost_text = { enabled = true },
		documentation = { auto_show = true, auto_show_delay_ms = 0 },
	},

	signature = { enabled = true },

	-- [THE FIX] PRIORITY CONFIGURATION
	-- [UPDATED] PRIORITY CONFIGURATION
	-- This forces LSP items (like std::cout) to the top of the list.
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },

		providers = {
			lsp = {
				name = "LSP",
				module = "blink.cmp.sources.lsp",
				score_offset = 1000, -- Boost LSP suggestions (Main Fix)
			},
			snippets = {
				name = "Snippets",
				module = "blink.cmp.sources.snippets",
				score_offset = 80, -- Lower priority for snippets
			},
			path = {
				name = "Path",
				module = "blink.cmp.sources.path",
				score_offset = 90,
			},
			buffer = {
				name = "Buffer",
				module = "blink.cmp.sources.buffer",
				score_offset = 50, -- Lowest priority for random words in file
			},
		},
	},

	fuzzy = { implementation = "prefer_rust_with_warning" },
})
