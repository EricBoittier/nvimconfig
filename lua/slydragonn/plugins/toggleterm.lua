return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({
			size = function(term)
				return term.direction == "vertical" and math.floor(vim.o.columns * 0.4) or 12
			end,
			open_mapping = [[<F7>]],
			shading_factor = 2,
			direction = "float",
			persist_mode = true,
			float_opts = {
				border = "curved",
				highlights = { border = "Normal", background = "Normal" },
			},
		})

		local Terminal = require("toggleterm.terminal").Terminal
		local claude = Terminal:new({
			cmd = "claude",
			count = 9,
			direction = "vertical",
			hidden = true, -- not touched by <F7>/ToggleTermToggleAll
			close_on_exit = false,
			on_open = function() vim.cmd("startinsert") end,
		})

		-- Type text into the Claude prompt without submitting it
		local function to_claude(text)
			local fresh = not claude.job_id
			if not claude:is_open() then claude:open() end
			vim.defer_fn(function() vim.api.nvim_chan_send(claude.job_id, text) end, fresh and 1500 or 0)
			claude:focus()
			vim.cmd("startinsert")
		end

		local rel = function() return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.") end
		local toggle = function() claude:toggle() end

		vim.keymap.set("n", "<leader>cc", toggle, { desc = "Toggle Claude Code" })
		vim.keymap.set("t", "<C-\\>c", toggle, { desc = "Hide Claude Code" })
		vim.keymap.set("n", "<leader>cf", function() to_claude("@" .. rel() .. " ") end, { desc = "Claude: @ current file" })
		vim.keymap.set("v", "<leader>cs", function()
			local a, b = vim.fn.line("v"), vim.fn.line(".")
			if a > b then a, b = b, a end
			vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
			to_claude(("@%s#L%d-%d "):format(rel(), a, b))
		end, { desc = "Claude: @ selected lines" })
	end,
}
