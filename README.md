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
- tmux >= 3.3 for the workflow below (`brew install tmux`)
- Optional, for LaTeX: `latexmk`, `sioyek`, and `neovim-remote` (`pipx install neovim-remote`)

## Install on a new machine

```bash
git clone https://github.com/EricBoittier/nvimconfig.git ~/nvimconfig   # any location
~/nvimconfig/install.sh            # no admin rights needed
~/nvimconfig/install.sh --sudo     # also install system packages (apt/dnf/pacman)
```

`install.sh` links nvim, kitty, tmux, fastfetch and starship into the config root, adds one
marked block to `~/.bashrc` / `~/.zshrc` that sources `shell/ricing.sh`, installs the
tools, and syncs plugins to `lazy-lock.json`. It is safe to re-run, and anything it
replaces is moved to `<name>.bak-<date>`.

- **Config root:** `$XDG_CONFIG_HOME`, else `~/.config`. On managed machines where
  `~/.config` is not writable it falls back to `~/.config-writable` and exports
  `XDG_CONFIG_HOME` from the shell rc.
- **Without admin rights (Linux):** nvim, tree-sitter, starship, zoxide, fastfetch, eza,
  fzf, kitty and FiraCode Nerd Font are installed as release binaries under `~/.local`.
  A compiler, `make`, `git`, Node.js and ripgrep cannot be installed this way; the
  script lists the ones that are missing.
- **With `--sudo`:** the same, plus those system packages from the package manager.
- **macOS:** everything comes from Homebrew.
- `--no-tools` only links and wires the rc, `--no-kitty` skips the terminal and font
  (servers), `--dry-run` prints the plan.

The manual steps in the sections below describe what the script does.

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
tmux/                            tmux.conf, `tm` sessionizer, claude-tmux launcher
shell/ricing.sh                  bash/zsh layer: banner, aliases, fzf, zoxide, starship
starship/ fastfetch/             prompt and opening-screen configs
fish/                            fish shell config
```

Everything in `plugins/` is picked up automatically by the `{ import = ... }`
calls in `lazy.lua` — to add a plugin, drop in a new file returning a lazy spec.

## Workflow: kitty + tmux + nvim

Three layers, each doing one job:

- **kitty** draws: true colour, ligatures, the translucent wallpaper, clickable links, images.
- **tmux** keeps state: one session per project, surviving closed windows, ssh drops and reboots of kitty.
- **nvim** edits, and shares one set of movement keys with tmux, so the pane/split boundary disappears.

### One-time setup

```bash
brew install tmux fzf zoxide eza fd bat ripgrep starship fastfetch   # core
ln -sfn ~/.config/nvim/kitty ~/.config/kitty
mkdir -p ~/.config/tmux && ln -sfn ~/.config/nvim/tmux/tmux.conf ~/.config/tmux/tmux.conf
ln -sfn ~/.config/nvim/starship/starship.toml ~/.config/starship.toml
ln -sfn ~/.config/nvim/fastfetch ~/.config/fastfetch
echo '[ -f ~/.config/nvim/shell/ricing.sh ] && source ~/.config/nvim/shell/ricing.sh' >> ~/.zshrc
```

Open nvim once so lazy.nvim installs the plugins (smart-splits must load at startup; it is
what tells tmux a pane is running nvim).

### The daily loop

1. **Open kitty, type `tm`.** A fuzzy list shows running sessions first, then your recent
   directories (zoxide) and every project under `~/Documents/github` and `~/Documents`.
   Pick one: a session named after the folder opens with window 1 `edit` running nvim and
   window 2 `sh`, both in the project directory. Pick it again later and you land exactly
   where you left off. `ta` re-attaches to the last session.
2. **Edit in nvim**, split freely. `Ctrl-h/j/k/l` moves between nvim splits *and* tmux
   panes with the same keys: at nvim's edge it hands over to tmux, and from a shell pane it
   steps back into nvim. `Alt-h/j/k/l` resizes the same way.
3. **Run things next to the editor.** `prefix |` splits a shell to the right, `prefix -`
   below, both in the current directory. Tests, servers, `claude`, logs.
4. **Pop up tools without disturbing the layout:** `prefix g` lazygit, `` prefix ` ``
   scratch shell, `prefix b` btop. They float over the session and vanish on exit.
5. **Jump between projects** with `prefix f` (all projects) or `prefix s` (running sessions
   only), each with a live preview. `ctrl-x` in the picker kills a session.
6. **Walk away.** Close kitty, sleep the laptop: sessions keep running. `tm` brings any of
   them back. Long Claude Code runs go in `claude-tmux` (see below).

### tmux keys

Prefix is `Ctrl-Space` (`Ctrl-b` also works).

| Key | Action |
| --- | --- |
| `Ctrl-h/j/k/l` | Move between panes and nvim splits (no prefix) |
| `Alt-h/j/k/l` | Resize panes and nvim splits (no prefix) |
| `prefix f` / `prefix s` | Project picker / session picker (popup) |
| `prefix \|` or `prefix \` / `prefix -` | Split right / below, same directory |
| `prefix c` | New window, same directory |
| `prefix Tab` | Last window; `prefix H` / `prefix L` previous / next |
| `prefix z` | Zoom the pane (status bar shows `zoom`) |
| `prefix x` | Kill pane, no confirmation |
| `prefix g` / `` prefix ` `` / `prefix b` | lazygit / scratch shell / btop popups |
| `prefix v` | Copy mode: `v` select, `Ctrl-v` block, `y` yank to the system clipboard |
| `prefix Ctrl-l` | Clear the screen (plain `Ctrl-l` is navigation) |
| `prefix r` | Reload tmux.conf |
| `prefix d` | Detach |

The config is plugin-free: no TPM to install. Details worth knowing:

- Yanks go to the macOS clipboard through OSC 52, which also works from tmux on a remote machine.
- `extended-keys` and `allow-passthrough` let kitty's key encoding and images reach nvim inside tmux.
- The status bar sits on top and is transparent so the kitty wallpaper shows through; it
  turns the session badge into an icon while the prefix is pressed.
- Closing the last window of a session moves you to another session instead of dropping out of tmux.
- Machine-specific tweaks go in `~/.config/tmux/local.conf` (not tracked).
- Shell-side trade-off: in a shell pane, `Ctrl-l` and `Ctrl-k` belong to navigation, so
  use `prefix Ctrl-l` to clear and `Ctrl-u` / `Ctrl-e` instead of kill-line.

### Shell extras (`shell/ricing.sh`)

`tm`, `ta`, `ll`/`la`/`tree` (eza), `cat` (bat), `z <dir>` (zoxide), `Ctrl-R` / `Ctrl-T` / `Alt-C`
(fzf history, files, cd), `mkcd`, `ports`, `weather`, `reload`. zsh-autosuggestions (grey
inline completion, accept with →) and zsh-syntax-highlighting are loaded when installed.

### Recommended extra tools

Everything degrades gracefully when these are missing; each one is worth installing:

```bash
brew install lazygit git-delta btop yazi tealdeer atuin direnv \
             zsh-autosuggestions zsh-syntax-highlighting
```

- **lazygit**: terminal git UI; `prefix g` opens it over the current project.
- **git-delta**: syntax-highlighted side-by-side diffs for `git diff`/`log`/`show`.
  Enable with `git config --global core.pager delta && git config --global interactive.diffFilter 'delta --color-only'`.
- **btop**: process/CPU/GPU monitor; `prefix b`.
- **yazi**: fast file manager with image previews in kitty.
- **tealdeer** (`tldr tar`): example-first man pages.
- **atuin**: searchable shell history in SQLite, optionally synced across machines (replaces `Ctrl-R`).
- **direnv**: per-project env vars and auto-activating venvs via `.envrc`.
- **zsh-autosuggestions / zsh-syntax-highlighting**: fish-style suggestions and live command colouring in zsh.

## Keymaps

Leader is <kbd>Space</kbd>.

### Editing & windows

| Key | Action |
| --- | --- |
| `<leader>w` | Save |
| `<leader>q` | Quit |
| `jk` (insert) | Escape to normal mode |
| `<leader>o` / `<leader>p` | Split vertical / horizontal |
| `<C-h/j/k/l>` | Move between windows and tmux panes (smart-splits) |
| `<A-h/j/k/l>` / `<C-arrows>` | Resize window (crosses into tmux too) |
| `<leader><leader>h/j/k/l` | Swap buffer with the neighbouring window |
| `s` / `S` | Flash: jump to any visible spot / select a treesitter node |
| `<Esc>` | Clear search highlight |
| visual `J` / `K` | Move selected lines down / up |
| `<leader>?` | Show buffer-local keymaps (press `<leader>` and wait for all of them) |
| `<leader>f` | Format file (or selection in visual mode) |
| `<F7>` | Floating terminal |

### Files & search

| Key | Action |
| --- | --- |
| `<leader>e` / `<leader>r` | Toggle / focus Neo-tree |
| `<leader>ff` / `<leader>fr` | Find files (incl. hidden) / recent files |
| `<leader>fg` / `<leader>fw` | Live grep / grep word under cursor |
| `<leader>/` | Fuzzy search in the current buffer |
| `<leader>fb` / `<leader>fh` / `<leader>fk` | Buffers / help / keymaps |
| `<leader>fd` / `<leader>ft` | Diagnostics / TODO comments |
| `<leader>f.` | Resume the last search |
| `<leader>fs` / `<leader>fc` | Git status / commits |

Telescope uses the native fzf sorter, so fzf syntax works in every picker:
`'exact`, `^prefix`, `suffix$`, `!exclude`.

### Diagnostics & TODOs (Trouble)

| Key | Action |
| --- | --- |
| `<leader>xx` / `<leader>xb` | Diagnostics for project / buffer |
| `<leader>xs` / `<leader>xr` | Symbols outline / LSP references side panel |
| `<leader>xq` / `<leader>xt` | Quickfix list / all TODOs |
| `]t` / `[t` | Next / previous TODO comment |

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
| `kitty.conf` | Main config (FiraCode 17pt, 0.72 opacity + blur, aurora wallpaper, remote control on) |
| `backgrounds/aurora.png` | Wallpaper behind the translucent background (Dracula-palette blobs) |
| `theme.conf` | Active color theme (Dracula, from [dexpota/kitty-themes](https://github.com/dexpota/kitty-themes)) |
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

## Ricing (bash, prompt, opening screen)

The aesthetic layer. Everything lives in this repo and is symlinked into place:

| Repo path | Linked to | Purpose |
| --- | --- | --- |
| `shell/ricing.sh` | sourced from `~/.bashrc` or `~/.zshrc` | Opening banner (once per top-level shell), modern-tool aliases, starship/zoxide/fzf init. Works in bash and zsh; every optional tool is guarded. |
| `fastfetch/config.jsonc` | `~/.config/fastfetch` | fastfetch layout for the opening screen |
| `starship/starship.toml` | `~/.config/starship.toml` | Starship prompt (Catppuccin Macchiato, powerline-style) |

Link the config files (all platforms):

```bash
ln -sfn ~/.config/nvim/fastfetch ~/.config/fastfetch
ln -sfn ~/.config/nvim/starship/starship.toml ~/.config/starship.toml
```

Load the shell layer. Add one line to the end of your shell rc:

```bash
# bash (Ubuntu, Fedora): ~/.bashrc
[ -f ~/.config/nvim/shell/ricing.sh ] && . ~/.config/nvim/shell/ricing.sh

# zsh (macOS default): ~/.zshrc
[ -f ~/.config/nvim/shell/ricing.sh ] && source ~/.config/nvim/shell/ricing.sh
```

On Fedora, `~/.bashrc` already loops over `~/.bashrc.d/`, so you can instead
`ln -sfn ~/.config/nvim/shell/ricing.sh ~/.bashrc.d/ricing.sh`.

Optional tools the layer picks up when present (none are required):

```bash
# Fedora
sudo dnf install fzf zoxide eza fd-find
# Ubuntu / Debian (eza may be missing from apt; the layer just skips it)
sudo apt install fzf zoxide fd-find bat
# macOS
brew install fzf zoxide eza fd bat starship fastfetch
```

Ubuntu installs `bat` as `batcat` and `fd` as `fdfind`; the layer handles both names.

The kitty `theme.conf` is machine-local and not tracked (see `.gitignore`), so on
a new machine link a theme into place as described above, or kitty will fall back to its defaults.

Switching the wallpaper: drop a PNG into `kitty/backgrounds/` and point
`background_image` at it in `kitty.conf`. Lower `background_opacity` for more
see-through; `background_tint` controls how much the image is washed out behind text.

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
- **Detach, don't babysit.** `prefix d` (`Ctrl-Space d` or `Ctrl-b d`) detaches; `tmux attach -t NAME` (or the
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
