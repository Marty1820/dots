# --- Early Exit for Non-Interactive Shells ---
if [[ $- == *i* ]]; then
    awk -v term_cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}" '
    BEGIN{
        s="/\\";
        for (colnum = 0; colnum < term_cols; colnum++) {
            r = 255 - (colnum * 255 / term_cols);
            g = (colnum * 510 / term_cols);
            if (g > 255) g = 510 - g;
            b = (colnum * 255 / term_cols);
            printf "\033[48;2;%d;%d;%dm", r, g, b;
            printf "\033[38;2;%d;%d;%dm", 255 - r, 255 - g, 255 - b;
            printf "%s\033[0m", substr(s, colnum % 2 + 1, 1);
        }
        printf "\n";
    }'
else
  exit
fi

# --- Terminal-Specific Aliases (Kitty) ---
if [ "$TERM" = "xterm-kitty" ]; then
  alias ssh="kitten ssh"
  alias icat="kitten icat"
  alias d="kitten diff"
fi

# --- Environment Variables ---
export HISTORY_IGNORE='(l[salt.]#( *)#|pwd|exit|history(|*)|cls)'
export HISTFILE="$XDG_CACHE_HOME/sh_hist"
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILESIZE=10000

# --- Home cleanup ---
alias wget='wget --hsts-file=$XDG_CACHE_HOME/wget-hsts'
alias adb='HOME="$XDG_DATA_HOME"/android adb'

# --- Aliases ---
alias v='nvim'
alias diff="nvim -d"
alias ..='cd ..'
alias mkdir='mkdir -p'
alias psa='ps auxf'
alias cls='clear -x'
alias nslookup='getent hosts'
alias jctl='journalctl -p 3 -xb'
alias cp='cp -i'
alias mv='mv -i'
alias df='df -h'
alias free='free -h'
alias du='du -h'
alias tree='tree -C'
alias grep='grep --color=auto'
alias egrep='grep -F --color=auto'
alias fgrep='grep -F --color=auto'
alias ip='ip --color=auto'
alias cat='bat'
alias ls='eza --icons=always --color=always --group-directories-first'
alias la='eza --all --icons=always --color=always --group-directories-first'
alias ll='eza --all --long --smart-group --icons=always --color=always --group-directories-first'
alias lt='eza --all --tree --icons=always --color=always --group-directories-first --ignore-glob=".git"'
alias l='eza --all --icons=always --color=always --group-directories-first'
alias l.='eza --all | grep -E "^\."'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
alias fetch='fastfetch'

# --- Zsh Options ---
# Directories
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS
# Expansion
setopt EXTENDED_GLOB NOMATCH
# Input/Output
setopt CORRECT
unsetopt beep
# Jobs
setopt NOTIFY
# History
setopt APPEND_HISTORY EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST \
  HIST_FIND_NO_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_DUPS \
  HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS

# --- Keybindings ---
bindkey -e
bindkey "^[[3~" delete-char

# --- Completion Setup ---
autoload -Uz compinit
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
compinit -d "$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
_comp_options+=(globdots)

# --- Man Pager & LESS Colors ---
export MANPAGER="nvim +Man!"
export GROFF_NO_SGR=1                   # for konsole
export LESS_TERMCAP_mb=$'\e[1;31m'      # bold (red)
export LESS_TERMCAP_md=$'\e[1;34m'      # blink (blue)
export LESS_TERMCAP_so=$'\e[01;45;37m'  # reverse (magenta bg, white fg)
export LESS_TERMCAP_us=$'\e[01;36m'     # underline (cyan)
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'

# --- Extract Function ---
[[ -f "$XDG_CONFIG_HOME"/zsh/extract.zsh ]] && source "$XDG_CONFIG_HOME"/zsh/extract.zsh

# --- Color Support ---
autoload -U colors && colors
[[ "$COLORTERM" == (24bit|truecolor) || "${terminfo[colors]}" -eq '16777216' ]] || zmodload zsh/nearcolor

# --- Prompt ---
eval "$(starship init zsh)"

# --- Plugins ---
# pacman -S zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  . /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ -f "$XDG_CONFIG_HOME"/zsh/colors.zsh ]] && source "$XDG_CONFIG_HOME"/zsh/colors.zsh

[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  . /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh && \
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6272a4,bold"
