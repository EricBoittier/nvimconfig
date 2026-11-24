-- Seamless Ctrl-h/j/k/l (move) and Alt-h/j/k/l (resize) across nvim splits and
-- tmux panes. Pairs with the bindings in tmux/tmux.conf. Must load at startup so
-- it can tag the tmux pane as "vim" (@pane-is-vim).
return {
	"smart-splits-nvim/smart-splits.nvim",
	lazy = false,
	-- v3 ships no multiplexer support itself; the tmux backend is its own plugin.
	dependencies = { { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" } },
	opts = {
		move = { at_edge = "stop" },
		resize = { amount = 3 },
		mux = { backend = "smart-splits-backend-tmux", warn_if_unusable = false },
	},
	keys = {
		{ "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Window/pane left" },
		{ "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Window/pane down" },
		{ "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Window/pane up" },
		{ "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Window/pane right" },
		{ "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize left" },
		{ "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize down" },
		{ "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize up" },
		{ "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize right" },
		{ "<C-Left>", function() require("smart-splits").resize_left() end, desc = "Resize left" },
		{ "<C-Down>", function() require("smart-splits").resize_down() end, desc = "Resize down" },
		{ "<C-Up>", function() require("smart-splits").resize_up() end, desc = "Resize up" },
		{ "<C-Right>", function() require("smart-splits").resize_right() end, desc = "Resize right" },
		{ "<leader><leader>h", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer left" },
		{ "<leader><leader>j", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer down" },
		{ "<leader><leader>k", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer up" },
		{ "<leader><leader>l", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer right" },
	},
}
