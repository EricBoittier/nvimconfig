-- Review workflow: branch diff (Diffview), hunk nav (gitsigns), triage → quickfix, GitHub PRs (Octo)
local base_cache = {}
local function base()
	if vim.g.review_base and vim.g.review_base ~= "" then
		return vim.g.review_base
	end
	local key = vim.trim(vim.fn.system("git rev-parse --git-dir 2>/dev/null"))
	if key ~= "" and base_cache[key] then
		return base_cache[key]
	end
	local detected = "origin/main"
	if vim.fn.executable("gh") == 1 then
		local pr_base = vim.trim(vim.fn.system("gh pr view --json baseRefName -q .baseRefName 2>/dev/null"))
		if vim.v.shell_error == 0 and pr_base ~= "" then
			for _, remote in ipairs({ "upstream", "origin" }) do
				vim.fn.system("git rev-parse --verify " .. remote .. "/" .. pr_base .. " >/dev/null 2>&1")
				if vim.v.shell_error == 0 then
					detected = remote .. "/" .. pr_base
					break
				end
			end
		end
	end
	if key ~= "" then
		base_cache[key] = detected
	end
	return detected
end

local function set_base()
	vim.ui.input({ prompt = "Review base ref: ", default = base() }, function(input)
		if input and input ~= "" then
			vim.g.review_base = vim.trim(input)
			vim.notify("review_base = " .. vim.g.review_base)
		end
	end)
end

local triage_file = function() return vim.trim(vim.fn.system("git rev-parse --git-path review-triage.qf")) end

local function hunk(dir)
	return function()
		if vim.wo.diff then return vim.cmd.normal({ dir == "next" and "]c" or "[c", bang = true }) end
		require("gitsigns").nav_hunk(dir)
	end
end

local function load_triage()
	local f = triage_file()
	if vim.fn.filereadable(f) == 0 then return vim.notify("No triage yet: run /triage or /pr-review in OpenCode", vim.log.levels.WARN) end
	vim.cmd.cfile(vim.fn.fnameescape(f))
	vim.cmd("copen")
end

local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc }) end
map("<leader>gb", set_base, "Review: set base branch (auto-detects PR base)")
map("<leader>gd", function() vim.cmd("DiffviewOpen " .. base() .. "...HEAD") end, "Review: branch diff vs base")
map("<leader>gc", function() vim.cmd("DiffviewFileHistory --range=" .. base() .. "..HEAD") end, "Review: commit by commit")
map("<leader>gf", "<cmd>DiffviewFileHistory %<cr>", "Review: history of this file")
map("<leader>gx", "<cmd>DiffviewClose<cr>", "Review: close diff")
map("<leader>gt", load_triage, "Review: load triage into quickfix")
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
			{ "<leader>oc", "<cmd>Octo pr checkout<cr>", desc = "GitHub: checkout PR" },
			{ "<leader>ov", "<cmd>Octo pr checks<cr>", desc = "GitHub: PR CI checks" },
			{ "<leader>or", "<cmd>Octo review start<cr>", desc = "GitHub: start review (drafts stay local until you submit)" },
			{ "<leader>oR", "<cmd>Octo review resume<cr>", desc = "GitHub: resume draft review" },
			{ "<leader>os", "<cmd>Octo review submit<cr>", desc = "GitHub: submit review" },
		},
	},
}
