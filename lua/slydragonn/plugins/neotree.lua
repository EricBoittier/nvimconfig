return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	opts = {
		commands = {
			-- open Neogit for the folder under the cursor (or the file's folder)
			neogit = function(state)
				local node = state.tree:get_node()
				local dir = node.type == "directory" and node.path or vim.fn.fnamemodify(node.path, ":h")
				require("neogit").open({ cwd = dir })
			end,
		},
		window = {
			mappings = {
				["gn"] = "neogit",
			},
		},
	},
}
