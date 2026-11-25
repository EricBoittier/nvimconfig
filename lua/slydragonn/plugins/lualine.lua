-- Statusline. Colours come from the kmode palette (lua/slydragonn/kmode.lua),
-- so it follows `kmode` / `:Kmode` like the rest of nvim.
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count
		local kmode = require("slydragonn.kmode")

		-- Mode → palette colour of the left-most block.
		local MODE_COLOURS = {
			normal = "blue",
			insert = "green",
			visual = "magenta",
			command = "yellow",
			replace = "red",
			terminal = "cyan",
		}

		local function theme()
			local p = kmode.palette
			local t = {}
			for mode, role in pairs(MODE_COLOURS) do
				t[mode] = {
					a = { bg = p[role], fg = p.bg, gui = "bold" },
					b = { bg = p.surface, fg = p[role] },
					c = { bg = p.surface, fg = p.fg },
				}
			end
			t.inactive = {
				a = { bg = p.surface, fg = p.dim, gui = "bold" },
				b = { bg = p.surface, fg = p.dim },
				c = { bg = p.surface, fg = p.dim },
			}
			return t
		end

		local function setup()
			lualine.setup({
				options = {
					theme = theme(),
					globalstatus = true,
				},
				sections = {
					lualine_x = {
						{
							lazy_status.updates,
							cond = lazy_status.has_updates,
							color = function()
								return { fg = kmode.palette.orange }
							end,
						},
						{ "encoding" },
						{ "fileformat" },
						{ "filetype" },
					},
				},
			})
		end

		setup()
		vim.api.nvim_create_autocmd("User", { pattern = "KmodeChanged", callback = setup })
	end,
}
