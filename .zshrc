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
  alias diff="nvim -d"
fi


# --- Environment Variables ---
export HISTORY_IGNORE='(l[salt.]#( *)#|pwd|exit|history(|*)|cls)'
export HISTFILE="$XDG_CACHE_HOME/sh_hist"
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILESIZE=10000
export EZA_COLORS="uu=36:uR=31:un=35:gu=37:da=2;34:ur=34:uw=95:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36:xx=95:"

# --- Home cleanup ---
alias wget='wget --hsts-file=$XDG_CACHE_HOME/wget-hsts'
alias adb='HOME="$XDG_DATA_HOME"/android adb'

# --- Aliases ---
alias v='nvim'
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
alias lt='eza --all --tree --icons=always --color=always --group-directories-first'
alias l='eza --all --icons=always --color=always --group-directories-first'
alias l.='eza --all | grep -E "^\."'
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
ex() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: ex <archive> [more archives...]"
    return 1
  fi

  for n in "$@"; do
    if [[ -f $n ]]; then      
      # Remove ALL extensions (archive.tar.gz > archive)
      dirname="${n%%.*}"
      dirname="${n%%.*}"
      dirname="${n%.*}"
      while [[ $dirname != "${dirname%.*}" ]]; do
        dirname="${dirname%.*}"
      done

      mkdir -p "$dirname" && cd "$dirname" || continue

      case $n in
        *.tar.bz2|*.tbz2|*.cbt) tar xvjf "../$n" ;;
        *.tar.gz|*.tgz)         tar xvzf "../$n" ;;
        *.tar.xz|*.txz)         tar xvJf "../$n" ;;
        *.tar.zst)              unzstd -c "../$n" | tar xvf - ;;
        *.tar)                  tar xvf "../$n" ;;
        *.lzma)                 unlzma "../$n" ;;
        *.bz2)                  bunzip2 "../$n" ;;
        *.gz)                   gunzip "../$n" ;;
        *.xz)                   unxz "../$n" ;;
        *.zip|*.cbz|*.epub)     unzip "../$n" ;;
        *.rar|*.cbr)            unrar x -ad "../$n" ;;
        *.7z|*.arj|*.cab|*.cb7|*.chm|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                                7z x "../$n" ;;
        *.deb)                  dpkg-deb -x "../$n" ./ ;;
        *.z)                    uncompress "../$n" ;;
        *.cpio)                 cpio -id < "../$n" ;;
        *.ace|*.cba)            unace x "../$n" ;;
        *.exe)                  cabextract "../$n" ;;
        *) echo "ex: '$n' - unknown format" ;;
      esac

      cd - >dev/null || true
    else
      echo "ex: '$n' - file not found"
    fi
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
