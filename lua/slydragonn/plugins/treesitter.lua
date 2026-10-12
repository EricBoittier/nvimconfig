return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		require("nvim-treesitter").setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})

		require("nvim-treesitter").install({
			"json",
			"javascript",
			"typescript",
			"tsx",
			"yaml",
			"html",
			"css",
			"markdown",
			"markdown_inline",
			"bash",
			"lua",
			"python",
			"fortran",
			"vim",
			"dockerfile",
			"gitignore",
			"c",
			"rust",
		})

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(args.match) or args.match
				if pcall(vim.treesitter.start, args.buf, lang) then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		require("nvim-ts-autotag").setup({})
	end,
}
