-- Start screen: an ASCII cat header with tonal shading, quick actions that
-- mirror the real keymaps, per-machine project jumps and reminders read from
-- a markdown file.

-- 42 columns x 28 rows. Edit freely, but keep every row 42 characters long
-- and keep SHADE in step with it (same size, one tone letter per character).
local LUNA = {
	"       ,                                  ",
	"       \\`-._           __                 ",
	"        \\\\  `-..____,.'  `.               ",
	"         :`.         /:.  \\`.             ",
	"         :. )       :::.   : \\            ",
	"          ;'        ':. ;  |  :           ",
	"          )..      .. .:.`.;  :           ",
	"         /::...  .:::...   ` ;            ",
	"         ; _ '    __        /:\\           ",
	"         `:o>   /\\o_>      ;:. `.         ",
	"        `-`.__ ;   __..--- /:.   \\        ",
	"        === \\_/   ;=====_.':.     ;       ",
	"         ,/'`--'...`--....        ;       ",
	"              ;:.                  ;      ",
	"            .':.                    ;     ",
	"          .'::.                     ;     ",
	"        .'::.  ..     ,      .       ;    ",
	"       ::.     ::..  /      ;::.     |    ",
	"      /:.    `.;::.  |       ;:..    ;    ",
	"     :::.      |:.   :       ;:.    ;     ",
	"     ::.       ::     ;:..   |.    ;      ",
	"      :.      :;      :::....|     |      ",
	"      /\\     ,/ \\      ;:::::;     ;      ",
	"    .:. \\:..|    :     ; '.--|     ;      ",
	"   ::.  :''  `-.,,;     ;'   ;     ;      ",
	".-'. _.'\\      / `;      \\,__:      \\     ",
	"`---'    `----'   ;      /    \\,.,,,/     ",
	"                   `----`                 ",
}

-- Tone of each character above: a = outline, b = shadow, c = deep shadow,
-- e = eyes, n = nose. Spaces are ignored.
local SHADE = {
	"       a                                  ",
	"       aaaaa           aa                 ",
	"        aa  aaaaaaaaaaa  aa               ",
	"         aaa         abc  aaa             ",
	"         ac a       abbc   a a            ",
	"          aa        abc a  a  a           ",
	"          acc      cc cbcaaa  a           ",
	"         abbccc  cbbbccc   a a            ",
	"         a a a    aa        aaa           ",
	"         aaea   aaeaa      abc aa         ",
	"        aaaaaa a   aaaaaaa abc   a        ",
	"        aaa nnn   aaaaaaaaabc     a       ",
	"         aaaaaaaaaaaaaaaaa        a       ",
	"              abc                  a      ",
	"            aabc                    a     ",
	"          aabbc                     a     ",
	"        aabbc  cc     a      a       a    ",
	"       abc     bbcc  a      abbc     a    ",
	"      abc    aaabbc  a       abcc    a    ",
	"     abbc      abc   a       abc    a     ",
	"     abc       bb     abcc   aa    a      ",
	"      ac      aa      bbbcccca     a      ",
	"      aa     aa a      abbbbba     a      ",
	"    bbb aaaaa    a     a aaaaa     a      ",
	"   bbb  aaa  aaaaaa     aa   a     a      ",
	"aaaa aaaa      a aa      aaaaa      a     ",
	"aaaaa    aaaaaa   a      a    aaaaaaa     ",
	"                   aaaaaa                 ",
}

local TONES = {
	a = "#e6e1cf",
	b = "#9a98a0",
	c = "#6b7684",
	e = "#ffb454",
	n = "#f07178",
}

-- Rows 1..HEAD_ROWS are the head alone, shown when the window is too short
-- for the whole cat.
local HEAD_ROWS = 13

-- Projects offered as number keys. Only directories that exist on this
-- machine are shown, so the list can cover several computers.
local PROJECTS = {
	{ "LongRangeBench", "~/LongRangeBench" },
	{ "karml", "~/karml-main" },
	{ "metatomic", "~/metatomic" },
	{ "metawork", "~/metawork" },
	{ "MD trajectories", "~/mlmm_traj" },
}

-- Open "- [ ]" items from this file are listed on the start screen. The file
-- is gitignored: this repo is public and to-dos are personal.
local REMINDERS = vim.fn.stdpath("config") .. "/reminders.md"

local QUIPS = {
	"∇θ L → 0, eventually",
	"E = Σ E_i + long-range, don't forget the long-range",
	"check the units before blaming the model",
	"one more epoch never hurt anyone (citation needed)",
	"energy conserved? then ship it",
	"plot the data before fitting the data",
}

local WIDTH = 58
local ICON = {
	new = "\u{f15b}", find = "\u{f002}", grep = "\u{f120}", recent = "\u{f1da}",
	tree = "\u{f07c}", session = "\u{f0e2}", git = "\u{f126}", github = "\u{f09b}",
	claude = "\u{f0eb}", config = "\u{f013}", plugins = "\u{f1b2}", quit = "\u{f011}",
	project = "\u{f0c3}", todo = "\u{f0ae}", edit = "\u{f044}", bolt = "\u{f0e7}",
}

-- Header ---------------------------------------------------------------------

-- Returns the first `rows` lines of the cat plus alpha's per-line highlight
-- ranges ({ group, byte_start, byte_end }); the art is ASCII, so bytes = columns.
local function render_cat(rows)
	local lines, hls = {}, {}
	for y = 1, math.min(rows, #LUNA) do
		local shade, ranges = SHADE[y], {}
		for x = 1, #shade do
			local tone = shade:sub(x, x)
			if tone ~= " " then
				local group = "AlphaCat_" .. tone
				local last = ranges[#ranges]
				if last and last[1] == group and last[3] == x - 1 then
					last[3] = x
				else
					ranges[#ranges + 1] = { group, x - 1, x }
				end
			end
		end
		lines[#lines + 1] = LUNA[y]
		hls[#hls + 1] = ranges
	end
	return lines, hls
end

-- Layout helpers -------------------------------------------------------------

-- Pad to the button width so centred text lines up with the buttons.
local function pad(text)
	local w = vim.fn.strdisplaywidth(text)
	if w > WIDTH then
		return vim.fn.strcharpart(text, 0, WIDTH - 1) .. "…"
	end
	return text .. string.rep(" ", WIDTH - w)
end

local function text(val, hl)
	return { type = "text", val = val, opts = { position = "center", hl = hl } }
end

local function section(title)
	return text(pad(title), "AlphaSection")
end

-- `action` is either keys to feed or a function. With no action, pressing
-- <CR> replays the shortcut itself, which also triggers lazy-loaded mappings.
local function button(shortcut, icon, label, action)
	local lhs = shortcut:gsub("%s", ""):gsub("SPC", "<leader>")
	local opts = {
		position = "center",
		shortcut = shortcut,
		cursor = 3,
		width = WIDTH,
		align_shortcut = "right",
		hl_shortcut = "AlphaShortcut",
		hl = { { "AlphaIcon", 0, #icon }, { "AlphaButton", #icon, -1 } },
	}
	if action then
		opts.keymap = { "n", lhs, action, { noremap = true, silent = true, nowait = true } }
	end
	return {
		type = "button",
		val = icon .. "  " .. label,
		opts = opts,
		on_press = function()
			if type(action) == "function" then
				return action()
			end
			local keys = vim.api.nvim_replace_termcodes(action or (lhs .. "<Ignore>"), true, false, true)
			vim.api.nvim_feedkeys(keys, "t", false)
		end,
	}
end

local function group(items)
	return { type = "group", val = items, opts = { spacing = 0 } }
end

-- Sections -------------------------------------------------------------------

local function project_buttons()
	local items = {}
	for _, project in ipairs(PROJECTS) do
		local name, dir = project[1], vim.fn.expand(project[2])
		if vim.fn.isdirectory(dir) == 1 then
			local key = tostring(#items + 1)
			items[#items + 1] = button(key, ICON.project, name, function()
				vim.cmd.cd(vim.fn.fnameescape(dir))
				require("telescope.builtin").find_files()
			end)
		end
	end
	return items
end

local function reminder_lines(max)
	local ok, content = pcall(vim.fn.readfile, REMINDERS)
	local lines = {}
	if ok then
		for _, raw in ipairs(content) do
			local item = raw:match("^%s*[-*]%s+%[ %]%s+(.+)$")
			if item then
				if #lines == max then
					lines[#lines] = lines[#lines]:gsub("%s*$", "") .. " …"
					break
				end
				lines[#lines + 1] = pad("  ☐ " .. item)
			end
		end
	end
	if #lines == 0 then
		lines[1] = pad("  nothing pending, press m to add a \"- [ ] item\"")
	end
	return lines
end

local function footer_line()
	local stats = require("lazy").stats()
	local version = vim.version()
	return ("%s %d/%d plugins in %.0f ms  ·  nvim %d.%d.%d  ·  %s"):format(
		ICON.bolt, stats.loaded, stats.count, stats.startuptime,
		version.major, version.minor, version.patch, os.date("%a %d %b")
	)
end

-- Highlights -----------------------------------------------------------------

local function set_highlights()
	for tone, colour in pairs(TONES) do
		vim.api.nvim_set_hl(0, "AlphaCat_" .. tone, { fg = colour })
	end
	-- Text follows the active colorscheme instead of fixed colours.
	for name, target in pairs({
		AlphaSection = "Title",
		AlphaButton = "Normal",
		AlphaIcon = "Function",
		AlphaShortcut = "Number",
		AlphaReminder = "String",
		AlphaDim = "Comment",
	}) do
		vim.api.nvim_set_hl(0, name, { link = target, default = true })
	end
end

return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		set_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })

		local actions = group({
			button("e", ICON.new, "New file", "<cmd>ene<CR>"),
			button("SPC ff", ICON.find, "Find file"),
			button("SPC fg", ICON.grep, "Grep in project"),
			button("r", ICON.recent, "Recent files", "<cmd>Telescope oldfiles<CR>"),
			button("SPC e", ICON.tree, "File tree"),
			button("SPC wr", ICON.session, "Restore session for this directory"),
			button("SPC gg", ICON.git, "Neogit status"),
			button("SPC op", ICON.github, "GitHub pull requests"),
			button("SPC cc", ICON.claude, "Claude Code"),
		})
		local system = group({
			button("m", ICON.edit, "Edit reminders", "<cmd>edit " .. vim.fn.fnameescape(REMINDERS) .. "<CR>"),
			button("c", ICON.config, "Edit config", function()
				vim.cmd.cd(vim.fn.fnameescape(vim.fn.stdpath("config")))
				require("telescope.builtin").find_files()
			end),
			button("L", ICON.plugins, "Plugins", "<cmd>Lazy<CR>"),
			button("q", ICON.quit, "Quit", "<cmd>qa<CR>"),
		})
		local footer = text(QUIPS[os.time() % #QUIPS + 1], "AlphaDim")
		local stats = text(" ", "AlphaDim")

		-- The layout shrinks with the window: the whole cat needs `rest + #LUNA`
		-- lines, below that only the head is drawn, and the blank rows between
		-- sections go first in either case. Anything that still overflows scrolls.
		local projects = project_buttons()
		local rest = 25 + #projects -- everything except the header and the gaps
		local gaps = 6
		local function whole_cat()
			return vim.o.lines >= rest + #LUNA
		end
		local gap = {
			type = "padding",
			val = function()
				local header_rows = whole_cat() and #LUNA or HEAD_ROWS
				return vim.o.lines >= rest + header_rows + gaps and 1 or 0
			end,
		}
		-- alpha reads opts.hl after calling val, so both are refreshed together
		-- on every redraw (including VimResized).
		local header = { type = "text", opts = { position = "center" } }
		header.val = function()
			local lines, hls = render_cat(whole_cat() and #LUNA or HEAD_ROWS)
			header.opts.hl = hls
			return lines
		end
		local layout = {
			gap,
			header,
			text("n e o v i m", "AlphaSection"),
			gap,
			actions,
		}
		if #projects > 0 then
			vim.list_extend(layout, { gap, section("Projects"), group(projects) })
		end
		vim.list_extend(layout, {
			gap,
			section("Reminders"),
			{
				type = "text",
				val = function()
					return reminder_lines(3)
				end,
				opts = { position = "center", hl = "AlphaReminder" },
			},
			gap,
			system,
			gap,
			footer,
			stats,
		})

		alpha.setup({ layout = layout, opts = { margin = 2 } })

		-- Startup time is only known once lazy.nvim has finished.
		vim.api.nvim_create_autocmd("User", {
			once = true,
			pattern = "LazyVimStarted",
			callback = function()
				stats.val = footer_line()
				pcall(vim.cmd.AlphaRedraw)
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "alpha",
			command = "setlocal nofoldenable",
		})
	end,
}
