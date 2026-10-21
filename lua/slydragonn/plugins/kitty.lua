return {
	"odysseyalive/kitty-themes.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("kitty-themes").setup({
			transparent = true,
			term_colors = true,
		})
		vim.cmd("colorscheme ayu")
	end,
}
