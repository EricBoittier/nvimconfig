-- In tabs mode the close button / right-click run :tabclose, which errors (E784) on the last tab
local function close_tab(handle)
	if #vim.api.nvim_list_tabpages() > 1 then
		vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(handle))
	else
		vim.notify("Last tab — use <leader>q to quit", vim.log.levels.INFO)
	end
end

return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	opts = {
		options = {
			mode = "tabs",
			close_command = close_tab,
			right_mouse_command = close_tab,
		},
	},
}
