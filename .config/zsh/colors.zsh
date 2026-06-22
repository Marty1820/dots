#!/bin/zsh
# Dracula Palette Variables
local dracula_green='#50FA7B'
local dracula_orange='#FFB86C'
local dracula_purple='#BD93F9'
local dracula_cyan='#8BE9FD'
local dracula_pink='#FF79C6'
local dracula_yellow='#F1FA8C'
local dracula_gray='#6272A4'
local dracula_white='#F8F8F2'
local dracula_red='#FF5555'

# https://github.com/zenorocha/dracula-theme
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES=(
  comment                      "fg=$dracula_gray"
  alias                        "fg=$dracula_green"
  suffix-alias                 "fg=$dracula_green"
  global-alias                 "fg=$dracula_green"
  function                     "fg=$dracula_green"
  command                      "fg=$dracula_green"
  precommand                   "fg=$dracula_green,italic"
  autodirectory                "fg=$dracula_orange,italic"
  single-hyphen-option         "fg=$dracula_orange"
  double-hyphen-option         "fg=$dracula_orange"
  back-quoted-argument         "fg=$dracula_purple"
  builtin                      "fg=$dracula_cyan"
  reserved-word                "fg=$dracula_cyan"
  hashed-command               "fg=$dracula_cyan"
  commandseparator             "fg=$dracula_pink"
  command-substitution-delimiter "fg=$dracula_white"
  process-substitution-delimiter "fg=$dracula_white"
  back-quoted-argument-delimiter 'fg=$dracula_pink'
  back-double-quoted-argument  "fg=$dracula_pink"
  back-dollar-quoted-argument  "fg=$dracula_pink"
  command-substitution-quoted  "fg=$dracula_yellow"
  single-quoted-argument       "fg=$dracula_yellow"
  double-quoted-argument       "fg=$dracula_yellow"
  rc-quote                     "fg=$dracula_yellow"
  dollar-quoted-argument       "fg=$dracula_white"
  assign                       "fg=$dracula_white"
  named-fd                     "fg=$dracula_white"
  numeric-fd                   "fg=$dracula_white"
  unknown-token                "fg=$dracula_red"
  path                         "fg=$dracula_white"
  globbing                     "fg=$dracula_white"
  history-expansion            "fg=$dracula_purple"
  redirection                  "fg=$dracula_white"
  arg0                         "fg=$dracula_white"
  default                      "fg=$dracula_white"
  cursor                       "standout"
)
unset dracula_green dracula_orange dracula_purple dracula_cyan dracula_pink dracula_yellow dracula_gray dracula_white dracula_red

# --- EZA colors ---
export EZA_COLORS="uu=36:uR=31:un=35:gu=37:da=2;34:ur=34:uw=95:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36:xx=95:"
