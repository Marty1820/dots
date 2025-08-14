# ███╗░░░███╗░█████╗░██████╗░████████╗
# ████╗░████║██╔══██╗██╔══██╗╚══██╔══╝
# ██╔████╔██║███████║██████╔╝░░░██║░░░
# ██║╚██╔╝██║██╔══██║██╔══██╗░░░██║░░░
# ██║░╚═╝░██║██║░░██║██║░░██║░░░██║░░░
# ╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░
# ZSH CONFIGUARATION

# --- Early Exit for Non-Interactive Shells ---
[[ $- != *i* ]] && return


# --- Terminal-Specific Aliases (Kitty) ---
if [ "$TERM" = "xterm-kitty" ]; then
  alias ssh="kitten ssh"
  alias icat="kitten icat"
  alias diff="kitten diff"
else
  alias diff="diff --color=auto"
fi


# --- Environment Variables ---
export HISTORY_IGNORE='(l[salt.]#( *)#|cd(|*)|~|pwd|exit|history(|*)|cls|nvim# *)'
export HISTFILE="$XDG_CACHE_HOME/sh_hist"
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILESIZE=10000
export EXA_COLORS="uu=36:gu=37:sn=32:sb=32:da=34:ur=34:uw=35:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36:"


# --- Aliases ---
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
alias ls='exa --icons --color=always --group-directories-first'
alias la='exa -a --icons --color=always --group-directories-first'
alias ll='exa -al --icons --color=always --group-directories-first'
alias lt='exa -aT --icons --color=always --group-directories-first'
alias l='exa -a --icons --color=always --group-directories-first'
alias l.='exa -a grep -E "^\."'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'


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
function ex {
  if [ -z "$1" ]; then
    echo "Usage: ex <file>..."
    return 1
  fi
  for n in "$@"; do
    [[ ! -f "$n" ]] && echo "'$n' is not a valid file" && return 1
    case "${n##*.}" in
      *.cbt|*.txz)        tar xvf ./"$n"      ;;
      *.7z|*.arj|*.cab|*.cb7|*.chm|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                          7z x ./"$n" ;;
      *.lzma)             unlzma ./"$n" ;;
      *.bz2)              bunzip2 ./"$n" ;;
      *.cbr|*.rar)        unrar x -ad ./"$n" ;;
      *.gz)               gunzip ./"$n" ;;
      *.cbz|*.epub|*.zip) unzip ./"$n" ;;
      *.z)                uncompress ./"$n";;
      *.xz)               unxz ./"$n" ;;
      *.tbz2)             tar xjf ./"$n" ;;
      *.tgz)              tar xzf ./"$n" ;;
      *.tar)              tar xf ./"$n" ;;
      *.deb)              ar x ./"$n" ;;
      *.tar.zst)          unzstd ./"$n" ;;
      *)                  echo "ex: '$n' - unknown archive method"
                          return 1 ;;
    esac
  done
}


# --- Color Support ---
autoload -U colors && colors
[[ "$COLORTERM" == (24bit|truecolor) || "${terminfo[colors]}" -eq '16777216' ]] || zmodload zsh/nearcolor


# --- Prompt ---
eval "$(starship init zsh)"


# --- Dracual Theme for zsh-syntax-highlighting ---
# https://github.com/zenorocha/dracula-theme
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES=(
  # Comments
  comment                      'fg=#6272A4'
  # Functions/Methods
  alias                        'fg=#50FA7B'
  suffix-alias                 'fg=#50FA7B'
  global-alias                 'fg=#50FA7B'
  function                     'fg=#50FA7B'
  command                      'fg=#50FA7B'
  precommand                   'fg=#50FA7B,italic'
  autodirectory                'fg=#FFB86C,italic'
  single-hyphen-option         'fg=#FFB86C'
  double-hyphen-option         'fg=#FFB86C'
  # Built-ins
  builtin                      'fg=#8BE9FD'
  reserved-word                'fg=#8BE9FD'
  hashed-command               'fg=#8BE9FD'
  # Punctuation
  commandseparator             'fg=#FF79C6'
  command-substitution-delimiter 'fg=#F8F8F2'
  process-substitution-delimiter 'fg=#F8F8F2'
  back-quoted-argument-delimiter 'fg=#FF79C6'
  back-double-quoted-argument 'fg=#FF79C6'
  back-dollar-quoted-argument 'fg=#FF79C6'
  # Strings
  command-substitution-quoted 'fg=#F1FA8C'
  single-quoted-argument      'fg=#F1FA8C'
  double-quoted-argument      'fg=#F1FA8C'
  rc-quote                    'fg=#F1FA8C'
  # Variables
  dollar-quoted-argument      'fg=#F8F8F2'
  assign                      'fg=#F8F8F2'
  named-fd                    'fg=#F8F8F2'
  numeric-fd                  'fg=#F8F8F2'
  # No Category Relevant in SPEC
  unknown-token               'fg=#FF5555'
  path                        'fg=#F8F8F2'
  globbing                    'fg=#F8F8F2'
  history-expansion           'fg=#BD93F9'
  redirection                 'fg=#F8F8F2'
  arg0                        'fg=#F8F8F2'
  default                     'fg=#F8F8F2'
  cursor                      'standout'
)

# --- Plugins ---
# pacman -S zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  . /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  . /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[ -f $HOME/.local/bin/color10bit.sh ] && $HOME/.local/bin/color10bit.sh

# --- SSH Setup ---
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [ ! -f "$SSH_AUTH_SOCK" ]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi
