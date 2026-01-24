-- ========================================================================== --
--  PLUGIN: SMEAR CURSOR
--  Animates the cursor with a smear effect (ghost trails).
-- ========================================================================== --

-- 1. INSTALL
vim.pack.add({
	"https://github.com/sphamba/smear-cursor.nvim",
})

-- 2. GUARD
local status, smear = pcall(require, "smear_cursor")
if not status then
	return
end

-- 3. CONFIGURE
smear.setup({
	-- General settings
	smear_between_buffers = true,
	smear_between_neighbor_lines = true,

	-- Draw in buffer space (better for scrolling)
	scroll_buffer_space = true,

	-- Set to true if your font supports legacy computing symbols (blocky chars)
	-- If false, it uses a fallback rendering method.
	legacy_computing_symbols_support = false,

	-- PERFORMANCE / VISUAL TUNING
	-- These settings make the smear faster and snappier.
	-- Comment them out if you prefer the slower default "gooey" feel.
	stiffness = 0.8,
	trailing_stiffness = 0.6,
	distance_stop_animating = 0.5,

	-- Insert mode handling
	smear_insert_mode = true,
})
