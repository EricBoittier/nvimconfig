vim.g.mapleader = " "

local function map(mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { silent = true })
end

-- Save
map("n", "<leader>w", "<CMD>update<CR>")

-- Quit
map("n", "<leader>q", "<CMD>q<CR>")

-- Exit insert mode
map("i", "jk", "<ESC>")

-- NeoTree
map("n", "<leader>e", "<CMD>Neotree toggle<CR>")
map("n", "<leader>r", "<CMD>Neotree focus<CR>")
map("n", "<leader>E", "<CMD>Neotree reveal<CR>") -- open the tree at the current file

-- New Windows
map("n", "<leader>o", "<CMD>vsplit<CR>")
map("n", "<leader>p", "<CMD>split<CR>")

-- Window navigation (Ctrl-h/j/k/l) and resizing (Alt-h/j/k/l, Ctrl-arrows) live in
-- plugins/smart-splits.lua so they cross seamlessly into tmux panes.

-- Clear search highlight
map("n", "<Esc>", "<CMD>nohlsearch<CR>")

-- Keep the cursor centred when paging / cycling search results
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Move selected lines up/down, keep selection when indenting
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Leaving terminal windows (Claude Code, toggleterm, ...)
-- Ctrl-w <dir> works straight from terminal mode (gives up Ctrl-w delete-word in the shell)
map("t", "<C-w>", "<C-\\><C-n><C-w>")
-- Alt-h/j/k/l jumps out of a terminal in one keystroke (kitty: left Option = Alt)
map("t", "<A-h>", "<C-\\><C-n><C-w>h")
map("t", "<A-j>", "<C-\\><C-n><C-w>j")
map("t", "<A-k>", "<C-\\><C-n><C-w>k")
map("t", "<A-l>", "<C-\\><C-n><C-w>l")


--map("i", "<C-l>", function()
--	require("copilot.suggestion").accept()
--end, { desc = "Copilot accept" })

vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false,
})

-- Copilot mappings
-- Use <C-J> to accept a suggestion]
-- Use <C-K> to reject a suggestion
vim.keymap.set("i", "<C-K>", "copilot#Reject()", {
	expr = true,
	replace_keycodes = false,
})
