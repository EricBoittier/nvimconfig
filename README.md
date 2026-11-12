# Neovim config

My personal Neovim setup — [lazy.nvim](https://github.com/folke/lazy.nvim) plugin
manager, [kitty-themes](https://github.com/odysseyalive/kitty-themes.nvim) (SeaShells) theme, LSP via
Mason, and a LaTeX workflow built on VimTeX + Sioyek.

Originally based on [slydragonn/nvim-lazy](https://github.com/slydragonn/nvim-lazy)
(hence the `lua/slydragonn/` namespace), since diverged.

![neovim setup](./images/lazy.jpg)

## Requirements

- Neovim >= 0.10
- A [Nerd Font](https://www.nerdfonts.com/font-downloads) in your terminal
- Git, a C compiler, and `make` (for treesitter parsers)
- Node.js + npm (for the TS/web language servers and Copilot)
- Optional, for LaTeX: `latexmk`, `sioyek`, and `neovim-remote` (`pipx install neovim-remote`)

## Install on a new machine

```bash
git clone https://github.com/EricBoittier/nvimconfig.git ~/.config/nvim
nvim
```

On first launch lazy.nvim bootstraps itself, installs every plugin at the exact
versions pinned in `lazy-lock.json`, and Mason pulls the language servers and
formatters. Let it finish, then restart.

To update plugins: `:Lazy sync`, then commit the refreshed `lazy-lock.json` so
your other machines land on the same versions.

## Layout

```
nvim/
├── init.lua                     entry point + LaTeX autocmd
└── lua/slydragonn/
    ├── settings.lua             vim options
    ├── maps.lua                 core keymaps (leader = space)
    ├── lazy.lua                 plugin-manager bootstrap
    └── plugins/                 one file per plugin, auto-imported
        └── lsp/                 lspconfig + mason
kitty/                           kitty terminal config (see below)
fish/                            fish shell config
```

Everything in `plugins/` is picked up automatically by the `{ import = ... }`
calls in `lazy.lua` — to add a plugin, drop in a new file returning a lazy spec.

## Keymaps

Leader is <kbd>Space</kbd>.

### Editing & windows

| Key | Action |
| --- | --- |
| `<leader>w` | Save |
| `<leader>q` | Quit |
| `jk` (insert) | Escape to normal mode |
| `<leader>o` / `<leader>p` | Split vertical / horizontal |
| `<C-h/j/k/l>` | Move between windows |
| `<C-arrows>` | Resize window |
| `<leader>f` | Format file (or selection in visual mode) |
| `<F7>` | Floating terminal |

### Files & search

| Key | Action |
| --- | --- |
| `<leader>e` / `<leader>r` | Toggle / focus Neo-tree |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fs` / `<leader>fc` | Git status / commits |

### LSP

| Key | Action |
| --- | --- |
| `gd` / `gD` | Definitions / declaration |
| `gR` / `gi` / `gt` | References / implementations / type definitions |
| `K` | Hover docs |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>d` / `<leader>D` | Line / buffer diagnostics |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>rs` | Restart LSP |

### Git & sessions

| Key | Action |
| --- | --- |
| `<leader>gg` | Neogit UI |
| `<leader>gd` / `<leader>gc` | Diffview: branch vs base / commit by commit (base = `vim.g.review_base`, default `origin/main`) |
| `<leader>gf` / `<leader>gx` | Diffview: history of this file / close |
| `<leader>gt` | Load Claude `/triage` output into quickfix |
| `]h` / `[h` | Next / previous hunk |
| `<leader>hp` / `<leader>hb` | Preview hunk / blame line |
| `<leader>op` / `<leader>or` | Octo: PR list / start review |
| `<leader>ws` / `<leader>wr` | Save / restore session for cwd |

### Claude Code

[claudecode.nvim](https://github.com/coder/claudecode.nvim) (replaced `avante.nvim`)
runs [Claude Code](https://claude.com/claude-code) in a right-hand split and connects
to it over the same IDE protocol as the VS Code extension: Claude sees your current
selection and open file, and proposed edits open as Neovim diffs you accept or reject.
Run `/ide` inside Claude if it doesn't connect on its own.

| Key | Action |
| --- | --- |
| `<leader>cc` / `<leader>co` | Toggle / focus Claude |
| `<leader>cr` / `<leader>cC` | Resume a conversation / continue the last one |
| `<leader>cm` | Pick model |
| `<leader>cf` | Add current file to context |
| `<leader>cs` (visual) | Send selection; in Neo-tree/nvim-tree adds the file under cursor |
| `<leader>cy` / `<leader>cn` | Accept / reject Claude's proposed diff |

`<leader>ca` stays LSP code actions.

### Copilot

| Key | Action |
| --- | --- |
| `<C-j>` (insert) | Accept suggestion |
| `<C-k>` (insert) | Reject suggestion |

Tab is deliberately left alone (`copilot_no_tab_map`). Run `:Copilot setup` once
per machine to authenticate.

## Language support

Language servers installed by Mason: `cssls`, `eslint`, `html`, `jsonls`,
`ts_ls`, `pyright`, `tailwindcss`.

Formatters (run on save via `conform.nvim`): `prettier` for web/JSON/YAML/
Markdown, `stylua` for Lua, `isort` + `black` for Python.

Treesitter parsers include the above plus `bash`, `fortran`, `dockerfile`, `vim`.

## LaTeX

`vimtex.lua` compiles with `latexmk -lualatex` and previews in Sioyek with
forward/inverse search wired through `nvr`. `init.lua` also sets `textwidth=65`
with auto-wrapping in `tex` buffers.

## Kitty

`kitty/` holds my [kitty](https://sw.kovidgoyal.net/kitty/) terminal config:

| File | Purpose |
| --- | --- |
| `kitty.conf` | Main config (FiraCode 17pt, 0.95 opacity + blur, remote control on) |
| `theme.conf` | Active color theme (Floraverse, from [dexpota/kitty-themes](https://github.com/dexpota/kitty-themes)) |
| `open-actions.conf` | What clicked links open (web/HTML/PDF/images → Chrome, dirs → Finder) |
| `startup.conf` / `startup.sh` | Startup session |
| `kmode` + `modes/` | `kmode dark\|light\|warm\|redshift\|contrast\|auto` swaps colour mode and live-reloads every kitty |

To install on a new machine, symlink it into place:

```bash
ln -s ~/.config/nvim/kitty ~/.config/kitty
```

Locally `theme.conf` is a symlink into a clone of `kitty-themes`; the repo
stores the resolved file so it works without that clone. To try other themes,
`git clone https://github.com/dexpota/kitty-themes ~/.config/kitty/kitty-themes`
and re-point `theme.conf`.

## Fish

`fish/config.fish` holds my fish shell config (currently just the `conda init`
hook). Install it the same way:

```bash
ln -s ~/.config/nvim/fish ~/.config/fish
```

## Tmux (on remote machines)

Things learned running long jobs and Claude Code sessions over ssh from kitty.

- **kitty's TERM breaks tmux on servers.** kitty sets `TERM=xterm-kitty`, and most
  HPC/lab machines have no terminfo entry for it, so `tmux` refuses to start (or
  draws garbage). Fixes, best first:
  - connect with `kitten ssh host` instead of `ssh host`: it copies kitty's terminfo
    to the remote automatically (and keeps shell integration);
  - or install it once by hand from the laptop:
    `infocmp -a xterm-kitty | ssh host tic -x -o ~/.terminfo /dev/stdin`;
  - or, as a stopgap, start tmux with `TERM=xterm-256color tmux ...`.
- **Detach, don't babysit.** `Ctrl+B d` detaches; `tmux attach -t NAME` (or the
  launcher below) gets you back. Jobs and sessions survive dropped ssh and laptop sleep.
- **Long-running Claude Code sessions: `tmux/claude-tmux`.** Starts `claude` detached
  in a named tmux session with Remote Control on, so the same conversation can be
  followed and driven from the phone or claude.ai while the terminal is closed.
  - `claude-tmux` attaches (starting the saved conversation if needed), `start` starts
    it detached, `fresh` begins a new conversation and remembers the old id, `status`
    shows what is running. It falls back to `xterm-256color` when the terminfo is missing.
  - Never run the same conversation in two processes at once.
  - `CLAUDE_TMUX_SETTINGS` points at a settings file used by this launcher only, the
    place for session hooks: a SessionStart hook that re-injects the project's plan
    and notes after `/compact` or `/clear`, and a PreCompact hook that snapshots
    recently changed files, keep a long session anchored to files instead of to
    stale context. `CLAUDE_TMUX_AUTOCOMPACT` compacts earlier to keep context lean.
  - Install: `ln -s ~/.config/nvim/tmux/claude-tmux ~/bin/claude-tmux`.

## Notes

- `lazy-lock.json` **is** committed on purpose — it's what keeps machines in sync.
- `.luarc.json` files are gitignored: lua_ls regenerates them with absolute
  `$HOME` paths, so they can't be shared.
- `pack/` is gitignored. It used to carry a second, vendored copy of
  `copilot.vim` that lazy.nvim already manages; plugins belong in `plugins/`.
