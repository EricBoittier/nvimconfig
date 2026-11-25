-- kmode.lua — one palette for kitty and nvim.
--
-- `kmode <name>` (kitty/kmode) records the mode in ~/.config/kitty/.kmode and
-- reloads kitty. This module reads that file, parses the matching
-- ~/.config/kitty/modes/<name>.conf and builds:
--
--   1. the nvim colorscheme (via kitty-themes.nvim), and
--   2. `M.palette`, named colours (red, green, dim, surface, ...) that every
--      other part of the config uses: lualine, the start screen, diagnostics,
--      diffs and Neogit. Nothing else hard-codes a colour.
--
-- To change colours:
--   * for one mode: edit kitty/modes/<name>.conf (kitty and nvim both follow);
--   * for every mode: edit ROLES (which theme slot each name uses) or
--     fix_highlights() below.
--
-- nvim re-checks the mode whenever it regains focus. `:Kmode <name>` switches
-- kitty and nvim together; `:Kmode` with no argument just re-applies.
-- Other modules can react to a mode change with:
--   vim.api.nvim_create_autocmd("User", { pattern = "KmodeChanged", callback = ... })
local M = {}

local uv = vim.uv or vim.loop

-- Mix colour a into b; t=0 gives b, t=1 gives a.
local function blend(a, b, t)
	local function ch(hex, i)
		return tonumber(hex:sub(i, i + 1), 16)
	end
	local out = "#"
	for _, i in ipairs({ 2, 4, 6 }) do
		out = out .. string.format("%02x", math.floor(ch(a, i) * t + ch(b, i) * (1 - t) + 0.5))
	end
	return out
end
M.blend = blend

-- Palette roles, in order. A string names a slot in the kitty theme file
-- (background, foreground, color0..color15, cursor, selection_background);
-- a function derives the colour from the roles above it.
local ROLES = {
	{ "bg", "background" },
	{ "fg", "foreground" },
	{ "red", "color1" },
	{ "green", "color2" },
	{ "yellow", "color3" },
	{ "blue", "color4" },
	{ "magenta", "color5" },
	{ "cyan", "color6" },
	{ "orange", function(p) return blend(p.red, p.yellow, 0.5) end },
	{ "dim", function(p) return blend(p.fg, p.bg, 0.55) end }, -- comments, inactive text
	{ "faint", function(p) return blend(p.fg, p.bg, 0.35) end }, -- line numbers, borders
	{ "surface", function(p) return blend(p.fg, p.bg, 0.12) end }, -- statusline, panels
}

-- Used when no mode file can be read.
local FALLBACK = {
	background = "#1a1b26", foreground = "#c0caf5",
	color1 = "#f7768e", color2 = "#9ece6a", color3 = "#e0af68",
	color4 = "#7aa2f7", color5 = "#bb9af7", color6 = "#7dcfff",
}

local function kitty_dir()
	local d = os.getenv("KITTY_CONFIG_DIRECTORY")
	if d and d ~= "" then
		return d
	end
	return (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/kitty"
end

local function read_first_line(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local line = f:read("*l")
	f:close()
	return line and vim.trim(line) or nil
end

local function macos_is_dark()
	if vim.fn.has("mac") == 0 then
		return true
	end
	local out = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
	return vim.v.shell_error == 0 and out:match("Dark") ~= nil
end

--- Name of the active mode: what kmode last wrote, "auto" resolved to dark/light.
function M.current()
	local m = read_first_line(kitty_dir() .. "/.kmode") or "default"
	if m == "auto" then
		m = macos_is_dark() and "dark" or "light"
	end
	return m
end

--- Parse a kitty theme file into { background=..., color0=..., ... }.
local function parse_conf(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local c = {}
	for line in f:lines() do
		local k, v = line:match("^%s*([%w_]+)%s+(#%x%x%x%x%x%x)")
		if k then
			c[k] = v:lower()
		end
	end
	f:close()
	return (c.background and c.foreground) and c or nil
end

local function build_palette(c)
	local p = {}
	for _, role in ipairs(ROLES) do
		local name, src = role[1], role[2]
		p[name] = type(src) == "function" and src(p) or c[src] or FALLBACK[src]
	end
	return p
end

--- The current palette (filled by M.apply; FALLBACK until then).
M.palette = build_palette(FALLBACK)

-- Highlights the generated kitty schemes get wrong, all from the palette.
local function fix_highlights(p)
	local bg, fg = p.bg, p.fg
	local set = function(g, o)
		vim.api.nvim_set_hl(0, g, o)
	end

	-- Selection: themes often use a pale selection colour without changing fg.
	set("Visual", { bg = blend(p.blue, bg, 0.35) })
	-- color8 is near-black in many themes; use derived greys instead.
	set("Comment", { fg = p.dim, italic = true })
	set("LineNr", { fg = p.faint })
	set("NonText", { fg = blend(fg, bg, 0.3) })
	set("WinSeparator", { fg = p.faint })
	set("FloatBorder", { fg = p.faint })

	-- Diagnostics: same hue for text, sign and the curly underline under the error.
	for name, col in pairs({ Error = p.red, Warn = p.yellow, Info = p.blue, Hint = p.cyan, Ok = p.green }) do
		set("Diagnostic" .. name, { fg = col })
		set("DiagnosticSign" .. name, { fg = col })
		set("DiagnosticUnderline" .. name, { undercurl = true, sp = col })
		set("DiagnosticVirtualText" .. name, { fg = col, bg = blend(col, bg, 0.1) })
	end
	-- Spelling mistakes (when :set spell is on).
	set("SpellBad", { undercurl = true, sp = p.red })
	set("SpellCap", { undercurl = true, sp = p.yellow })
	set("SpellRare", { undercurl = true, sp = p.magenta })
	set("SpellLocal", { undercurl = true, sp = p.cyan })

	-- Line diffs: tinted backgrounds, normal text colour on top (diffview, :diff).
	set("DiffAdd", { bg = blend(p.green, bg, 0.22) })
	set("DiffDelete", { bg = blend(p.red, bg, 0.22) })
	set("DiffChange", { bg = blend(p.blue, bg, 0.15) })
	set("DiffText", { bg = blend(p.blue, bg, 0.35), bold = true })
	set("Added", { fg = p.green })
	set("Removed", { fg = p.red })
	set("Changed", { fg = p.yellow })
	set("GitSignsAdd", { fg = p.green })
	set("GitSignsChange", { fg = p.yellow })
	set("GitSignsDelete", { fg = p.red })

	-- Neogit only fills groups that are still unset, so these win.
	set("NeogitDiffContext", { bg = blend(fg, bg, 0.05) })
	set("NeogitDiffContextHighlight", { bg = blend(fg, bg, 0.09) })
	set("NeogitDiffContextCursor", { bg = blend(fg, bg, 0.14) })
	set("NeogitDiffAdd", { fg = fg, bg = blend(p.green, bg, 0.18) })
	set("NeogitDiffAddHighlight", { fg = fg, bg = blend(p.green, bg, 0.28) })
	set("NeogitDiffAddCursor", { fg = p.green, bg = blend(fg, bg, 0.14) })
	set("NeogitDiffDelete", { fg = fg, bg = blend(p.red, bg, 0.18) })
	set("NeogitDiffDeleteHighlight", { fg = fg, bg = blend(p.red, bg, 0.28) })
	set("NeogitDiffDeleteCursor", { fg = p.red, bg = blend(fg, bg, 0.14) })
	set("NeogitHunkHeader", { fg = fg, bg = p.surface, bold = true })
	set("NeogitHunkHeaderHighlight", { fg = fg, bg = blend(p.magenta, bg, 0.4), bold = true })
	set("NeogitHunkHeaderCursor", { fg = fg, bg = blend(p.magenta, bg, 0.4), bold = true })
	set("NeogitDiffHeader", { fg = p.blue, bg = blend(p.blue, bg, 0.15), bold = true })
	set("NeogitDiffHeaderHighlight", { fg = p.blue, bg = blend(p.blue, bg, 0.25), bold = true })
	set("NeogitCursorLine", { bg = blend(fg, bg, 0.1) })
end

local applied -- "<mode>@<mtime>" last applied, to skip no-op reloads

--- Load the current kmode palette as the nvim colorscheme.
function M.apply(force)
	local dir = kitty_dir()
	local stat = uv.fs_stat(dir .. "/.kmode")
	local mode = M.current()
	local key = mode .. "@" .. (stat and stat.mtime.sec or 0)
	if key == applied and not force then
		return
	end
	applied = key

	-- modes/<mode>.conf, falling back to the machine-local base theme.
	local colors = parse_conf(dir .. "/modes/" .. mode .. ".conf") or parse_conf(dir .. "/theme.conf") or FALLBACK
	M.palette = build_palette(colors)

	local name = "kmode-" .. mode
	local ok, kt = pcall(require, "kitty-themes")
	if ok then
		require("kitty-themes.embedded").themes[name] = colors
		kt.load(name)
	else
		vim.cmd("colorscheme habamax")
	end
	fix_highlights(M.palette)
	vim.api.nvim_exec_autocmds("ColorScheme", { pattern = name, modeline = false })
	vim.api.nvim_exec_autocmds("User", { pattern = "KmodeChanged", modeline = false })
end

function M.setup()
	M.apply(true)

	vim.api.nvim_create_autocmd("FocusGained", {
		group = vim.api.nvim_create_augroup("kmode", { clear = true }),
		callback = function()
			M.apply(false)
		end,
	})

	vim.api.nvim_create_user_command("Kmode", function(opts)
		local m = opts.args
		if m ~= "" then
			local out = vim.fn.system({ kitty_dir() .. "/kmode", m })
			if vim.v.shell_error ~= 0 then
				vim.notify(out, vim.log.levels.ERROR)
				return
			end
		end
		M.apply(true)
		vim.notify("kmode → " .. M.current())
	end, {
		nargs = "?",
		desc = "Switch kitty + nvim colour mode (no arg: re-apply current)",
		complete = function()
			local names = { "auto" }
			for f in vim.fs.dir(kitty_dir() .. "/modes") do
				table.insert(names, (f:gsub("%.conf$", "")))
			end
			return names
		end,
	})
end

return M
