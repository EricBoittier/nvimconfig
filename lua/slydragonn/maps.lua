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

-- New Windows
map("n", "<leader>o", "<CMD>vsplit<CR>")
map("n", "<leader>p", "<CMD>split<CR>")

-- Window Navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-j>", "<C-w>j")

-- Leaving terminal windows (Claude Code, toggleterm, ...)
-- Ctrl-w <dir> works straight from terminal mode (gives up Ctrl-w delete-word in the shell)
map("t", "<C-w>", "<C-\\><C-n><C-w>")
-- Alt-h/j/k/l jumps out of a terminal in one keystroke (kitty: left Option = Alt)
map("t", "<A-h>", "<C-\\><C-n><C-w>h")
map("t", "<A-j>", "<C-\\><C-n><C-w>j")
map("t", "<A-k>", "<C-\\><C-n><C-w>k")
map("t", "<A-l>", "<C-\\><C-n><C-w>l")

-- Resize Windows
map("n", "<C-Left>", "<C-w><")
map("n", "<C-Right>", "<C-w>>")
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")

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
