-- General-purpose terminal on <F7>. Claude Code lives in claudecode.lua.
return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		size = function(term)
			return term.direction == "vertical" and math.floor(vim.o.columns * 0.4) or 12
		end,
		open_mapping = [[<F7>]],
		shading_factor = 2,
		direction = "float",
		persist_mode = true,
		float_opts = {
			border = "curved",
			highlights = { border = "Normal", background = "Normal" },
		},
	},
}
