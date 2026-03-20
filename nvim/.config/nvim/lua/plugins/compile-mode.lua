-- ========================================================================== --
--  PLUGIN: COMPILE-MODE.NVIM
-- ========================================================================== --

-- 1. Install using your native pack manager
vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	{
		src = "https://github.com/ej-shafran/compile-mode.nvim",
		version = vim.version.range("5.*"),
	},
})

-- 2. Helper function to read compile_flags.txt
local function get_compile_flags(default_flags)
	local f = io.open("compile_flags.txt", "r")
	if not f then
		return default_flags
	end
	local content = f:read("*a")
	f:close()
	return content:gsub("\n", " ")
end

-- 3. Configure Compile Mode
vim.g.compile_mode = {
	auto_jump_to_first_error = true,
	ask_about_save = true,

	default_command = function()
		local ft = vim.bo.filetype
		local file = vim.fn.expand("%")
		local out = vim.fn.expand("%<")

		-- Project Level (Build Systems)
		if vim.fn.filereadable("Cargo.toml") == 1 then
			return "cargo run"
		elseif vim.fn.filereadable("CMakeLists.txt") == 1 then
			return 'cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build && exe=$(find build -maxdepth 2 -type f -executable -not -path \'*/.*\' | xargs ls -t | head -n1); if [ -n "$exe" ]; then ./"$exe"; fi'
		elseif vim.fn.filereadable("Makefile") == 1 then
			return "make && ./$(ls -t | grep -v '\\.' | head -n1)"
		end

		-- Single File Level (Scripts & Compilers)
		if ft == "cpp" then
			local flags =
				get_compile_flags("-std=c++23 -Wall -Wextra -pedantic")
			return string.format(
				"clang++ %s '%s' -o '%s' && ./'%s'",
				flags,
				file,
				out,
				out
			)
		elseif ft == "c" then
			local flags =
				get_compile_flags("-std=c23 -Wall -Wextra -pedantic -lm")
			return string.format(
				"clang %s '%s' -o '%s' && ./'%s'",
				flags,
				file,
				out,
				out
			)
		elseif ft == "rust" then
			return string.format("rustc '%s' && ./'%s'", file, out)
		elseif ft == "python" then
			return string.format("python3 '%s'", file)
		elseif ft == "bash" or ft == "sh" then
			return string.format("bash '%s'", file)
		elseif ft == "javascript" then
			return string.format("node '%s'", file)
		elseif ft == "typescript" then
			return string.format("npx tsx '%s'", file)
		elseif ft == "lua" then
			return string.format("nvim -l '%s'", file)
		end

		return "make "
	end,
}
