-- Colorscheme: follows the kitty colour mode set with `kmode` (see lua/slydragonn/kmode.lua).
-- kitty-themes.nvim turns the kitty palette into nvim highlights; kmode.lua then
-- fixes the diff/Neogit/selection groups so they stay readable in every mode.
return {
	"odysseyalive/kitty-themes.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("kitty-themes").setup({
			transparent = true, -- let kitty's translucent wallpaper show through
			term_colors = true,
		})
		require("slydragonn.kmode").setup()
	end,
}
