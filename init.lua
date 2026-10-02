--vim.cmd("set foldmethod=indent")
require("slydragonn.settings")
require("slydragonn.maps")
require("slydragonn.lazy")

-- Automatically break lines in LaTeX files at 80 characters
vim.api.nvim_create_autocmd("FileType", {
	pattern = "tex",
	callback = function()
		vim.opt_local.textwidth = 65 -- Set maximum line length to 80 characters
		vim.opt_local.formatoptions:append("t") -- Enable automatic line breaking
	end,
})
