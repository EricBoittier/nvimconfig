return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	-- Build native libs from source: the prebuilt macOS release links against a
	-- /nix/store libiconv. Needs rustup's rustc (Homebrew's is too old) and Apple
	-- clang (/usr/local/bin/c++ is GCC, which rejects -stdlib=libc++).
	build = 'PATH="$HOME/.cargo/bin:$PATH" CC=/usr/bin/clang CXX=/usr/bin/clang++ make BUILD_FROM_SOURCE=true',
	version = false, -- avante: never pin to "*"
	opts = {
		-- add any opts here
	},
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		{ "ColinKennedy/mega.cmdparse", dependencies = { "ColinKennedy/mega.logging" } },
		--- The below is optional, make sure to setup it properly if you have lazy=true
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
