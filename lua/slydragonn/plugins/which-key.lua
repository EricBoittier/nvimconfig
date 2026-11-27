-- Press <leader> (Space) and wait: a popup lists every mapping. <leader>? = buffer-local keys.
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		delay = 300,
		spec = {
			{ "<leader>a", group = "opencode" },
			{ "<leader>c", group = "code / claude" },
			{ "<leader>f", group = "find" },
			{ "<leader>g", group = "git" },
			{ "<leader>h", group = "hunks" },
			{ "<leader>o", group = "octo / split" },
			{ "<leader>r", group = "rename / restart" },
			{ "<leader>w", group = "save / session" },
			{ "<leader>x", group = "diagnostics" },
			{ "<leader><leader>", group = "swap buffers" },
		},
	},
	keys = {
		{ "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer keymaps" },
	},
}
