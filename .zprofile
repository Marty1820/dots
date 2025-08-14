# ███╗░░░███╗░█████╗░██████╗░████████╗
# ████╗░████║██╔══██╗██╔══██╗╚══██╔══╝
# ██╔████╔██║███████║██████╔╝░░░██║░░░
# ██║╚██╔╝██║██╔══██║██╔══██╗░░░██║░░░
# ██║░╚═╝░██║██║░░██║██║░░██║░░░██║░░░
# ╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░


# --- XDG Base Directories ---
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_STATE_HOME="$HOME"/.local/state
export XDG_CACHE_HOME="$HOME"/.cache


# --- Environment Defaults ---
export EDITOR=nvim
export GIT_EDITOR=nvim
export VISUAL=nvim
export DIFFPROG='nvim -d'


# --- Application-Secific Env ---
export LIBVA_DRIVER_NAME='i965'
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export PYTHONSTARTUP="/etc/python/pythonrc"
export WGETRC="$XDG_CONFIG_HOME"/wgetrc


# --- Dev / SDKs / Tools ---
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export ANDROID_HOME="$XDG_DATA_HOME"/android
export ANDROID_USER_HOME="$XDG_DATA_HOME"/android
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel


# --- Ansible ---
export ANSIBLE_HOME="$XDG_CONFIG_HOME"/ansible
export ANSIBLE_CONFIG="$XDG_CONFIG_HOME"/ansible/ansible.cfg
export ANSIBLE_GALAXY_CACHE_DIR="$XDG_CACHE_HOME"/ansible/galaxy_cache


# --- NPM ---
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME"/npm/config/npm-init.js
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME"/npm
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"/npm


# --- PATH Setup ---
[[ -d "$HOME/.bin" ]] && PATH="$HOME/.bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/Applications" ]] && PATH="$HOME/Applications:$PATH"
[[ -d "$HOME/Scripts" ]] && PATH="$HOME/Scripts:${PATH}"
