-- Claude Code IDE integration: speaks the same WebSocket/MCP protocol as the
-- VS Code extension, so Claude sees your selection and proposes edits as diffs.
return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	opts = {
		terminal = { split_side = "right", split_width_percentage = 0.4 },
	},
	keys = {
		{ "<leader>c", nil, desc = "Claude Code" },
		{ "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude: toggle" },
		{ "<leader>co", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: focus" },
		{ "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Claude: resume a conversation" },
		{ "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continue last conversation" },
		{ "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: select model" },
		{ "<leader>cf", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add current file" },
		{ "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: send selection" },
		{ "<leader>cs", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Claude: add file from tree", ft = { "neo-tree" } },
		{ "<leader>cy", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff" },
		{ "<leader>cn", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: reject diff" },
	},
}
