# zsh fix for FPATH
zsh_root_dir=/apps/daint/SSL/tnikolov/spack/opt/spack/cray-cnl7-haswell/gcc-8.3.0/zsh-5.8-5q6u6m75sj4x34ofykts3cb5mwwgvpm6
fpath=($zsh_root_dir/share/zsh/$ZSH_VERSION/functions $fpath)
#fpath=(/usr/share/zsh/functions $fpath)
#export FPATH="/usr/share/zsh/functions:$FPATH"
#
# proper handling of carets `^`
unsetopt   extendedglob

# ----
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="${XDG_STATE_HOME}"/zsh/history

# vi mode
bindkey -v
export KEYTIMEOUT=1

# [Ctrl-Delete] - delete whole forward-word
bindkey -M viins '^[[3;5~' kill-word
bindkey -M vicmd '^[[3;5~' kill-word
# [Ctrl-RightArrow] - move forward one word
bindkey -M viins '^[[1;5C' forward-word
bindkey -M vicmd '^[[1;5C' forward-word
# [Ctrl-LeftArrow] - move backward one word
bindkey -M viins '^[[1;5D' backward-word
bindkey -M vicmd '^[[1;5D' backward-word
# [Ctrl-s] don't freez the terminal
stty stop undef
# [Backspace] - delete backward
bindkey "^?" backward-delete-char
# [Ctrl-x-e] edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# cd - stack old directories
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
# automatically cd into typed directory
setopt autocd

# highlight selected entry from completion menu
zstyle ':completion:*' menu select
# case-insensitive and hiphen-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

# aliases
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"

# spack
SPACK_SKIP_MODULES="" # speedup sourcing `setup-env.sh`
source ${HOME}/code/spack/share/spack/setup-env.sh

# direnv
# eval "$(direnv hook zsh)"

# fzf
#source /usr/share/fzf/key-bindings.zsh
#source /usr/share/fzf/completion.zsh

# zsh-autosuggestions
source ${HOME}/code/zsh-autosuggestions/zsh-autosuggestions.zsh

# p10k theme
source ${HOME}/code/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
