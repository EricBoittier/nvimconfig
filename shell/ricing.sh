# ricing.sh — interactive niceties: opening screen, modern tool aliases, prompt.
# Works in bash (Fedora, Ubuntu, macOS /bin/bash) and zsh (macOS default).
# Source it from ~/.bashrc or ~/.zshrc (see README "Ricing"). Every optional
# tool is guarded, so a missing binary never breaks the shell.
[[ $- == *i* ]] || return 0

_rice_zsh=0
[[ -n ${ZSH_VERSION:-} ]] && _rice_zsh=1
_rice_mac=0
[[ $(uname -s) == Darwin ]] && _rice_mac=1

# ---- helpers -----------------------------------------------------------------

# Colour a string with a cyan→violet 256-colour gradient.
rice_gradient() {
  local s=$1 i ch n k=7
  local codes=(51 45 39 33 69 105 141)
  n=${#s}
  if (( _rice_zsh )); then
    # zsh strings are 1-indexed; ${s[i]} is character-aware.
    for (( i = 1; i <= n; i++ )); do
      ch=${s[i]}
      printf '\e[1;38;5;%dm%s' "${codes[(i - 1) * k / n + 1]}" "$ch"
    done
  else
    for (( i = 0; i < n; i++ )); do
      printf '\e[1;38;5;%dm%s' "${codes[i * k / n]}" "${s:i:1}"
    done
  fi
  printf '\e[0m'
}

# ---- opening screen ----------------------------------------------------------
# Runs once per top-level shell; the export keeps subshells and nested shells quiet.

rice_banner() {
  local hour greet quotes idx q uptime_str line
  hour=$(date +%H)
  if   (( 10#$hour < 5 ));  then greet="Burning the midnight oil"
  elif (( 10#$hour < 12 )); then greet="Good morning"
  elif (( 10#$hour < 18 )); then greet="Good afternoon"
  else                           greet="Good evening"
  fi
  quotes=(
    "Simplicity is prerequisite for reliability. — E. W. Dijkstra"
    "Talk is cheap. Show me the code. — L. Torvalds"
    "Premature optimization is the root of all evil. — D. Knuth"
    "It works on my machine. — everyone, eventually"
    "Works now. Don't touch it. — every shell prompt"
  )
  idx=$(( RANDOM % ${#quotes[@]} ))
  if (( _rice_zsh )); then q=${quotes[idx+1]}; else q=${quotes[idx]}; fi

  # uptime: `uptime -p` is GNU-only; macOS prints a different format, so skip it there.
  uptime_str=""
  if (( ! _rice_mac )); then uptime_str=$(uptime -p 2>/dev/null | sed 's/^up //'); fi
  line="$(date '+%A %d %B · %H:%M')"
  [[ -n $uptime_str ]] && line+=" · up $uptime_str"

  printf '\n  '
  rice_gradient "░▒▓█ ${USER}@$(hostname -s) █▓▒░"
  printf '\n\n  \e[1m%s, %s\e[0m  \e[90m· %s\e[0m\n' "$greet" "$USER" "$line"
  printf '  \e[3;90m“%s”\e[0m\n\n' "$q"

  if command -v fastfetch >/dev/null 2>&1; then
    fastfetch -c "$HOME/.config/fastfetch/config.jsonc"
  fi
}

if [[ -z ${RICE_BANNER_SHOWN:-} ]]; then
  export RICE_BANNER_SHOWN=1
  rice_banner
fi

# ---- aliases (modern replacements, only when installed) ----------------------

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lh --git --group-directories-first --icons=auto'
  alias la='eza -la --git --group-directories-first --icons=auto'
  alias tree='eza --tree --icons=auto'
elif (( _rice_mac )); then
  alias ll='ls -lhG'
else
  alias ll='ls -lh --color=auto'
fi

# Debian/Ubuntu package bat as `batcat` and fd as `fdfind`.
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --style=plain'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never --style=plain'
fi

if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
fi

if command -v fd >/dev/null 2>&1; then
  : # already named fd
elif command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

alias ff='fastfetch -c "$HOME/.config/fastfetch/config.jsonc"'
alias weather='curl -s "wttr.in/?format=3"'
if (( _rice_mac )); then
  alias ports='lsof -iTCP -sTCP:LISTEN -n -P'
else
  alias ports='ss -tulpn'
fi
if (( _rice_zsh )); then alias reload='exec zsh'; else alias reload='exec bash'; fi
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# ---- prompt and navigation ---------------------------------------------------

if command -v fzf >/dev/null 2>&1; then
  if (( _rice_zsh )); then
    source <(fzf --zsh 2>/dev/null)     # Ctrl-R history, Ctrl-T files, Alt-C cd
  else
    eval "$(fzf --bash 2>/dev/null)"
  fi
fi

if command -v zoxide >/dev/null 2>&1; then
  if (( _rice_zsh )); then
    eval "$(zoxide init zsh)"           # use: z <partial-dir>
  else
    eval "$(zoxide init bash)"
  fi
fi

# Starship last so it owns the prompt. Config: ~/.config/starship.toml
if command -v starship >/dev/null 2>&1; then
  if (( _rice_zsh )); then
    eval "$(starship init zsh)"
  else
    eval "$(starship init bash)"
  fi
fi
