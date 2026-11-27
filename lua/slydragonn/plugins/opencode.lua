-- nickjvandyke/opencode.nvim: talks to a running `opencode` server and injects
-- editor context (@this, @buffer, @diagnostics, @quickfix).
-- Tracks main (OpenCode v2 API); the running background service is v2.x.
return {
	"nickjvandyke/opencode.nvim",
	dependencies = { "folke/snacks.nvim" },
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {}
	end,
	-- Upstream suggests <C-a>/<C-x>, which would shadow Vim's increment/decrement,
	-- so these live under <leader>a instead.
	keys = {
		{ "<leader>a", nil, desc = "OpenCode" },
		{ "<leader>aa", function() require("opencode").ask("@this: ") end, mode = { "n", "x" }, desc = "OpenCode: ask about @this" },
		{ "<leader>ab", function() require("opencode").ask("@buffer: ") end, mode = { "n", "x" }, desc = "OpenCode: ask about @buffer" },
		{ "<leader>aq", function() require("opencode").ask("@quickfix: ") end, mode = "n", desc = "OpenCode: ask about @quickfix" },
		{ "<leader>as", function() require("opencode").select() end, mode = { "n", "x" }, desc = "OpenCode: select prompt/action" },
		{ "go", function() return require("opencode").operator("@this") end, mode = { "n", "x" }, expr = true, desc = "Send range to OpenCode" },
		{ "goo", function() return require("opencode").operator("@this") .. "_" end, expr = true, desc = "Send line to OpenCode" },
	},
}
