-- carlos-algms/agentic.nvim: generic ACP chat client, configured for OpenCode.
return {
	"carlos-algms/agentic.nvim",
	---@type agentic.PartialUserConfig
	opts = {
		provider = "opencode-acp",
	},
	keys = {
		{ "<C-\\>", function() require("agentic").toggle() end, mode = { "n", "v", "i" }, desc = "Agentic: toggle chat" },
		{ "<C-'>", function() require("agentic").add_selection_or_file_to_context() end, mode = { "n", "v" }, desc = "Agentic: add file/selection to context" },
		{ "<C-,>", function() require("agentic").new_session() end, mode = { "n", "v", "i" }, desc = "Agentic: new session" },
		{ "<leader>ar", function() require("agentic").restore_session() end, desc = "Agentic: restore session" },
		{ "<leader>ad", function() require("agentic").add_current_line_diagnostics() end, desc = "Agentic: add line diagnostic" },
		{ "<leader>aD", function() require("agentic").add_buffer_diagnostics() end, desc = "Agentic: add buffer diagnostics" },
	},
}
