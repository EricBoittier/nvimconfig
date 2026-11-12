-- Review workflow: branch diff (Diffview), hunk nav (gitsigns), Claude triage → quickfix, GitHub PRs (Octo)
local base = function() return vim.g.review_base or "origin/main" end
local triage_file = function() return vim.trim(vim.fn.system("git rev-parse --git-path review-triage.qf")) end

local function hunk(dir)
	return function()
		if vim.wo.diff then return vim.cmd.normal({ dir == "next" and "]c" or "[c", bang = true }) end
		require("gitsigns").nav_hunk(dir)
	end
end

local function load_triage()
	local f = triage_file()
	if vim.fn.filereadable(f) == 0 then return vim.notify("No triage yet: run /triage in Claude", vim.log.levels.WARN) end
	vim.cmd.cfile(vim.fn.fnameescape(f))
	vim.cmd("copen")
end

local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc }) end
map("<leader>gd", function() vim.cmd("DiffviewOpen " .. base() .. "...HEAD") end, "Review: branch diff vs base")
map("<leader>gc", function() vim.cmd("DiffviewFileHistory --range=" .. base() .. "..HEAD") end, "Review: commit by commit")
map("<leader>gf", "<cmd>DiffviewFileHistory %<cr>", "Review: history of this file")
map("<leader>gx", "<cmd>DiffviewClose<cr>", "Review: close diff")
map("<leader>gt", load_triage, "Review: load Claude triage into quickfix")
map("]h", hunk("next"), "Next hunk")
map("[h", hunk("prev"), "Prev hunk")
map("<leader>hp", function() require("gitsigns").preview_hunk() end, "Preview hunk")
map("<leader>hb", function() require("gitsigns").blame_line({ full = true }) end, "Blame line")

return {
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
		opts = { enhanced_diff_hl = true, view = { merge_tool = { layout = "diff3_mixed" } } },
	},
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		dependencies = { "nvim-lua/plenary.nvim", "ibhagwan/fzf-lua", "nvim-tree/nvim-web-devicons" },
		opts = { picker = "fzf-lua", enable_builtin = true },
		keys = {
			{ "<leader>op", "<cmd>Octo pr list<cr>", desc = "GitHub: PR list" },
			{ "<leader>or", "<cmd>Octo review start<cr>", desc = "GitHub: start review (drafts stay local until you submit)" },
		},
	},
}
