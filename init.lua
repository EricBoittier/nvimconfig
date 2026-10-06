--vim.cmd("set foldmethod=indent")
require("slydragonn.settings")
require("slydragonn.maps")
require("slydragonn.lazy")

-- OpenCode ACP setup
require("oc-companion").setup({
  -- ACP is already configured by default with:
  -- command = "opencode", args = { "acp" }
  -- You can customize here if needed:
  -- server = {
  --   command = "/absolute/path/bin/opencode",
  --   args = { "acp" },
  --   env = {
  --     OPENCODE_API_KEY = os.getenv("OPENCODE_API_KEY"),
  --   },
  -- },
})

-- Automatically break lines in LaTeX files at 80 characters
vim.api.nvim_create_autocmd("FileType", {
	pattern = "tex",
	callback = function()
		vim.opt_local.textwidth = 65 -- Set maximum line length to 80 characters
		vim.opt_local.formatoptions:append("t") -- Enable automatic line breaking
	end,
})
