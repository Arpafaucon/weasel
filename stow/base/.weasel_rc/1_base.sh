#!/bin/bash

# explicitly added to avoid a weird error in ghostty
# LC_ALL was en_FR-u-hc-h23-u-ca-gregory-u-nu-latn
# powerlevel10k was complaining at boot of
# "bash: warning: setlocale: LC_ALL: cannot change locale (en_FR-u-hc-h23-u-ca-gregory-u-nu-latn): Invalid argument"
export LC_ALL=en_IE.UTF-8


# History
export HISTSIZE=100000
export SAVEHIST=$HISTSIZE

setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt SHARE_HISTORY             # Share history between all sessions.

autoload -Uz compinit && compinit

#compdef gt
###-begin-gt-completions-###
#
# yargs command completion script
#
# Installation: gt completion >> ~/.zshrc
#    or gt completion >> ~/.zprofile on OSX.
#
_gt_yargs_completions()
{
  local reply
  local si=$IFS
  # shellcheck disable=SC2207,SC2034,SC2154
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" gt --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _gt_yargs_completions gt
###-end-gt-completions-###

eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"


autoload -U +X bashcompinit && bashcompinit

# fzf config
# Using bat as previewer
# shellcheck disable=SC1090
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--tmux" # only available on recent tmux versions
export FZF_CTRL_T_OPTS="--preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'"
