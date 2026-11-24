#!/usr/bin/env bash
# install.sh — set this repo up on a new machine: nvim, kitty, shell layer, tools.
#
#   git clone https://github.com/EricBoittier/nvimconfig.git ~/nvimconfig   # anywhere
#   ~/nvimconfig/install.sh            # no admin rights needed
#   ~/nvimconfig/install.sh --sudo     # also install system packages (apt/dnf)
#
# Options:
#   --sudo       use sudo + the system package manager for compilers, node, ripgrep ...
#   --no-tools   only link configs and wire the shell rc; download nothing
#   --no-kitty   skip installing the kitty terminal and its font (e.g. on servers)
#   --dry-run    print what would be done
#   -h, --help
#
# What it does (safe to re-run; anything it replaces is moved to <name>.bak-<date>):
#   1. picks the config root: $XDG_CONFIG_HOME, else ~/.config, else ~/.config-writable
#      when ~/.config cannot be written (managed machines);
#   2. links nvim, kitty, fastfetch, starship.toml into it and claude-tmux into ~/.local/bin;
#   3. adds one marked block to ~/.bashrc and/or ~/.zshrc that sources shell/ricing.sh;
#   4. installs tools. Linux: release binaries into ~/.local (no root), plus distro
#      packages with --sudo. macOS: Homebrew.
#   5. syncs nvim plugins to lazy-lock.json.
set -euo pipefail

SUDO=0 TOOLS=1 KITTY=1 DRY=0
for a in "$@"; do
  case $a in
    --sudo) SUDO=1 ;;
    --no-tools) TOOLS=0 ;;
    --no-kitty) KITTY=0 ;;
    --dry-run) DRY=1 ;;
    -h|--help) sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $a (see --help)" >&2; exit 2 ;;
  esac
done

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
STAMP=$(date +%Y%m%d-%H%M%S)
OS=$(uname -s) ARCH=$(uname -m)
BIN=$HOME/.local/bin
WARN=()

say()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }
warn() { WARN+=("$*"); printf '\033[1;33m !! \033[0m %s\n' "$*"; }
run()  { if (( DRY )); then printf '    [dry-run] %s\n' "$*"; else "$@"; fi; }
have() { command -v "$1" >/dev/null 2>&1 || [[ -x $BIN/$1 ]]; }

# ---- 1. config root ----------------------------------------------------------

writable_dir() {  # can $1 be used as a config dir (existing or creatable)?
  local d=$1
  if [[ -d $d ]]; then [[ -w $d ]]; else [[ -w $(dirname "$d") ]]; fi
}

SET_XDG=0
if [[ -n ${XDG_CONFIG_HOME:-} ]] && writable_dir "$XDG_CONFIG_HOME"; then
  CFG=$XDG_CONFIG_HOME
elif writable_dir "$HOME/.config"; then
  CFG=$HOME/.config
else
  CFG=$HOME/.config-writable
  SET_XDG=1
  warn "~/.config is not writable; using $CFG and exporting XDG_CONFIG_HOME from the shell rc"
fi
[[ $CFG != "$HOME/.config" ]] && SET_XDG=1
say "config root: $CFG   repo: $REPO"
run mkdir -p "$CFG" "$BIN"

# ---- 2. links ----------------------------------------------------------------

link() {  # link SRC DEST, backing up whatever is in the way
  local src=$1 dest=$2
  if [[ $(readlink -f "$dest" 2>/dev/null || true) == "$(readlink -f "$src")" ]]; then
    note "ok       $dest"; return
  fi
  if [[ -e $dest || -L $dest ]]; then
    note "backup   $dest -> $dest.bak-$STAMP"
    run mv "$dest" "$dest.bak-$STAMP"
  fi
  note "link     $dest -> $src"
  run ln -s "$src" "$dest"
}

say "linking configs"
link "$REPO"                        "$CFG/nvim"
link "$REPO/kitty"                  "$CFG/kitty"
link "$REPO/fastfetch"              "$CFG/fastfetch"
link "$REPO/starship/starship.toml" "$CFG/starship.toml"
link "$REPO/tmux/claude-tmux"       "$BIN/claude-tmux"
link "$REPO/kitty/kmode"            "$BIN/kmode"

# kitty/theme.conf is machine-local (gitignored). Seed it from an older config if one
# was just moved aside, else from the repo's default mode.
if [[ ! -e $REPO/kitty/theme.conf ]]; then
  old=$(ls -d "$CFG"/kitty.bak-*/current-theme.conf "$CFG"/kitty.bak-*/theme.conf 2>/dev/null | head -1 || true)
  note "seed     kitty/theme.conf from ${old:-kitty/modes/default.conf}"
  run cp "${old:-$REPO/kitty/modes/default.conf}" "$REPO/kitty/theme.conf"
fi

# ---- 3. shell rc -------------------------------------------------------------

BEGIN="# >>> nvimconfig >>>" END="# <<< nvimconfig <<<"
rc_block() {
  echo "$BEGIN"
  echo "# Managed by $REPO/install.sh; re-run it instead of editing this block."
  (( SET_XDG )) && echo "export XDG_CONFIG_HOME=\"$CFG\""
  echo 'case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac'
  echo "[ -f \"$REPO/shell/ricing.sh\" ] && . \"$REPO/shell/ricing.sh\""
  echo "$END"
}
wire_rc() {
  local rc=$1 tmp
  if (( DRY )); then note "[dry-run] write nvimconfig block to $rc"; return; fi
  touch "$rc"
  tmp=$(mktemp)
  # drop any previous block, then append the current one
  awk -v b="$BEGIN" -v e="$END" '$0==b{skip=1} !skip{print} $0==e{skip=0}' "$rc" > "$tmp"
  { cat "$tmp"; [[ -s $tmp && -n $(tail -c1 "$tmp") ]] && echo; rc_block; } > "$tmp.new"
  if cmp -s "$tmp.new" "$rc"; then note "ok       $rc"
  else cp "$rc" "$rc.bak-$STAMP"; cat "$tmp.new" > "$rc"; note "updated  $rc (backup $rc.bak-$STAMP)"; fi
  rm -f "$tmp" "$tmp.new"
}
say "wiring shell rc"
wired=0
if [[ -f $HOME/.bashrc || $(basename "${SHELL:-bash}") == bash ]]; then wire_rc "$HOME/.bashrc"; wired=1; fi
if [[ -f $HOME/.zshrc  || $(basename "${SHELL:-}") == zsh ]];      then wire_rc "$HOME/.zshrc";  wired=1; fi
(( wired )) || wire_rc "$HOME/.bashrc"

# ---- 4. tools ----------------------------------------------------------------

fetch() { curl -fsSL --retry 3 "$1"; }
gh_dl() { echo "https://github.com/$1/releases/latest/download/$2"; }

# untar URL into ~/.local/opt/NAME and link the given binaries (paths inside the tree)
opt_install() {
  local name=$1 url=$2; shift 2
  local dest=$HOME/.local/opt/$name tmp
  if (( DRY )); then note "[dry-run] $name <- $url"; return; fi
  tmp=$(mktemp -d)
  fetch "$url" > "$tmp/a" || { warn "$name: download failed ($url)"; rm -rf "$tmp"; return; }
  mkdir -p "$tmp/x"
  case $url in
    *.zip) unzip -q "$tmp/a" -d "$tmp/x" ;;
    *)     tar -xf "$tmp/a" -C "$tmp/x" ;;
  esac
  rm -rf "$dest"; mkdir -p "$(dirname "$dest")"; mv "$tmp/x" "$dest"; rm -rf "$tmp"
  local b f
  for b in "$@"; do
    f=$(find "$dest" -type f -path "*$b" | head -1)
    if [[ -n $f ]]; then chmod +x "$f"; ln -sfn "$f" "$BIN/$(basename "$b")"
    else warn "$name: $b not found in archive"; fi
  done
  note "installed $name"
}

tools_linux() {
  local a_gnu a_nvim a_ts a_ff a_fzf
  case $ARCH in
    x86_64)        a_gnu=x86_64  a_nvim=x86_64 a_ts=x64   a_ff=amd64   a_fzf=amd64 ;;
    aarch64|arm64) a_gnu=aarch64 a_nvim=arm64  a_ts=arm64 a_ff=aarch64 a_fzf=arm64 ;;
    *) warn "unsupported architecture $ARCH: install the tools by hand"; return ;;
  esac

  if (( SUDO )); then
    say "system packages (sudo)"
    if command -v apt-get >/dev/null; then
      run sudo apt-get update
      run sudo apt-get install -y git curl unzip xz-utils build-essential nodejs npm \
        ripgrep fd-find bat tmux fontconfig
    elif command -v dnf >/dev/null; then
      run sudo dnf install -y git curl unzip xz gcc gcc-c++ make nodejs npm \
        ripgrep fd-find bat tmux fontconfig
    elif command -v pacman >/dev/null; then
      run sudo pacman -S --needed --noconfirm git curl unzip xz base-devel nodejs npm \
        ripgrep fd bat tmux fontconfig
    else
      warn "no apt/dnf/pacman found; skipping system packages"
    fi
  fi

  say "user-space tools -> ~/.local"
  have nvim || opt_install nvim "$(gh_dl neovim/neovim "nvim-linux-$a_nvim.tar.gz")" /bin/nvim
  if ! have tree-sitter; then
    if (( DRY )); then note "[dry-run] tree-sitter"; else
      fetch "$(gh_dl tree-sitter/tree-sitter "tree-sitter-linux-$a_ts.gz")" | gunzip > "$BIN/tree-sitter" \
        && chmod +x "$BIN/tree-sitter" && note "installed tree-sitter" || warn "tree-sitter: download failed"
    fi
  fi
  have starship || { note "starship"; (( DRY )) || fetch https://starship.rs/install.sh | sh -s -- -y -b "$BIN" >/dev/null \
        || warn "starship: install failed"; }
  have zoxide   || { note "zoxide";   (( DRY )) || fetch https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
        | sh -s -- --bin-dir "$BIN" >/dev/null || warn "zoxide: install failed"; }
  have fastfetch || opt_install fastfetch "$(gh_dl fastfetch-cli/fastfetch "fastfetch-linux-$a_ff.tar.gz")" /bin/fastfetch
  have eza       || opt_install eza "$(gh_dl eza-community/eza "eza_$a_gnu-unknown-linux-gnu.tar.gz")" /eza
  if ! have fzf; then
    # fzf asset names carry the version; resolve it from the latest-release redirect
    local v
    v=$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/junegunn/fzf/releases/latest | sed 's|.*/v||')
    [[ -n $v ]] && opt_install fzf "https://github.com/junegunn/fzf/releases/download/v$v/fzf-$v-linux_$a_fzf.tar.gz" /fzf \
      || warn "fzf: could not resolve latest version"
  fi

  if (( KITTY )); then
    if ! have kitty && [[ ! -x $HOME/.local/kitty.app/bin/kitty ]]; then
      note "kitty -> ~/.local/kitty.app"
      (( DRY )) || fetch https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n >/dev/null \
        || warn "kitty: install failed"
    fi
    for b in kitty kitten; do
      [[ -x $HOME/.local/kitty.app/bin/$b ]] && run ln -sfn "$HOME/.local/kitty.app/bin/$b" "$BIN/$b"
    done
    if ! fc-list 2>/dev/null | grep -qi "FiraCode Nerd Font"; then
      note "FiraCode Nerd Font -> ~/.local/share/fonts"
      if (( ! DRY )); then
        mkdir -p "$HOME/.local/share/fonts/FiraCodeNerd"
        fetch "$(gh_dl ryanoasis/nerd-fonts FiraCode.tar.xz)" | tar -xJ -C "$HOME/.local/share/fonts/FiraCodeNerd" \
          && { fc-cache -f >/dev/null 2>&1 || true; } || warn "FiraCode Nerd Font: install failed"
      fi
    fi
  fi

  # Things only a package manager (or you) can provide.
  local t
  for t in git curl cc make node npm; do
    command -v $t >/dev/null || warn "$t missing: needed by nvim plugins/LSP servers$( ((SUDO)) || echo ' (re-run with --sudo, or ask an admin)')"
  done
  command -v rg >/dev/null || warn "ripgrep missing: Telescope live grep will not work"
}

tools_mac() {
  if ! command -v brew >/dev/null; then
    warn "Homebrew not found: install it from https://brew.sh and re-run"; return
  fi
  say "Homebrew packages"
  run brew install neovim tree-sitter-cli starship fastfetch fzf zoxide eza fd bat ripgrep node tmux
  if (( KITTY )); then run brew install --cask kitty font-fira-code-nerd-font; fi
}

if (( TOOLS )); then
  case $OS in
    Linux)  tools_linux ;;
    Darwin) tools_mac ;;
    *) warn "unsupported OS $OS: install the tools by hand" ;;
  esac
fi

# ---- 5. nvim plugins ---------------------------------------------------------

NVIM=$(command -v nvim || true); [[ -z $NVIM && -x $BIN/nvim ]] && NVIM=$BIN/nvim
if (( TOOLS )) && [[ -n $NVIM ]]; then
  say "syncing nvim plugins to lazy-lock.json"
  # The first start installs missing plugins and may rewrite the lockfile from what it
  # found, so put the tracked lockfile back before restoring to it.
  if (( ! DRY )); then
    export XDG_CONFIG_HOME=$CFG PATH=$BIN:$PATH
    "$NVIM" --headless "+Lazy! install" +qa >/dev/null 2>&1 || true
    git -C "$REPO" checkout -- lazy-lock.json 2>/dev/null || true
    "$NVIM" --headless "+Lazy! restore" +qa >/dev/null 2>&1 || warn "nvim plugin restore reported errors: open nvim and run :Lazy"
  fi
elif (( TOOLS )); then
  warn "nvim not found: plugins not synced"
fi

echo
say "done"
if (( ${#WARN[@]} )); then
  echo "Warnings:"; printf '  - %s\n' "${WARN[@]}"
fi
echo "Open a new shell (or: exec \$SHELL) to load the shell layer."
