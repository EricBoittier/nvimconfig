local global = vim.g
local o = vim.opt

o.number = true
o.relativenumber = true
o.clipboard = "unnamedplus"
o.syntax = "on"
o.autoindent = true
o.cursorline = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.encoding = "UTF-8"
o.ruler = true
o.mouse = "a"
o.title = true
o.hidden = true
o.ttimeoutlen = 0
o.wildmenu = true
o.showcmd = true
o.showmatch = true
o.inccommand = "split"
o.splitright = true
o.splitbelow = true
o.termguicolors = true

-- Ergonomics
o.signcolumn = "yes"        -- no text jump when diagnostics/git signs appear
o.scrolloff = 8
o.sidescrolloff = 8
o.undofile = true           -- undo history survives restarts
o.ignorecase = true
o.smartcase = true          -- case-sensitive only when the pattern has capitals
o.updatetime = 250          -- faster CursorHold (diagnostics float, gitsigns)
o.timeoutlen = 400          -- which-key pops up quickly
o.laststatus = 3            -- one global statusline
o.splitkeep = "screen"      -- splits don't make the text jump
o.confirm = true            -- ask instead of failing on :q with unsaved changes
o.breakindent = true
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.fillchars = { eob = " " } -- hide the ~ on empty lines
o.pumheight = 12

-- Briefly flash yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})
