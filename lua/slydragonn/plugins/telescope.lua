return {
	"nvim-telescope/telescope.nvim",
	tag = "v0.2.2", -- 0.1.x calls nvim-treesitter APIs that its main branch removed
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- native fzf sorter: faster, and supports fzf syntax ('exact ^prefix suffix$ !not)
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			defaults = {
				prompt_prefix = "   ",
				selection_caret = " ",
				sorting_strategy = "ascending",
				layout_config = { prompt_position = "top" },
				path_display = { "truncate" },
				file_ignore_patterns = { "%.git/", "node_modules/", "%.venv/", "__pycache__/" },
			},
			pickers = {
				find_files = { hidden = true },
			},
		})
		pcall(telescope.load_extension, "fzf")

		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { desc = desc })
		end
		map("<leader>ff", "<cmd>Telescope find_files<cr>", "Find files")
		map("<leader>fg", "<cmd>Telescope live_grep<cr>", "Live grep")
		map("<leader>fw", "<cmd>Telescope grep_string<cr>", "Grep word under cursor")
		map("<leader>fb", "<cmd>Telescope buffers<cr>", "Buffers")
		map("<leader>fr", "<cmd>Telescope oldfiles<cr>", "Recent files")
		map("<leader>fh", "<cmd>Telescope help_tags<cr>", "Help")
		map("<leader>fk", "<cmd>Telescope keymaps<cr>", "Keymaps")
		map("<leader>fd", "<cmd>Telescope diagnostics<cr>", "Diagnostics")
		map("<leader>f.", "<cmd>Telescope resume<cr>", "Resume last search")
		map("<leader>fs", "<cmd>Telescope git_status<cr>", "Git status")
		map("<leader>fc", "<cmd>Telescope git_commits<cr>", "Git commits")
		map("<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Search in buffer")
	end,
}
