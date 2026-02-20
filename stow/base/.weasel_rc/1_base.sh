#!/bin/bash

# explicitly added to avoid a weird error in ghostty
# LC_ALL was en_FR-u-hc-h23-u-ca-gregory-u-nu-latn
# powerlevel10k was complaining at boot of
# "bash: warning: setlocale: LC_ALL: cannot change locale (en_FR-u-hc-h23-u-ca-gregory-u-nu-latn): Invalid argument"
export LC_ALL=en_IE.UTF-8

eval "$(dd-gitsign load-key)"

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
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--tmux"
export FZF_CTRL_T_OPTS="--preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'"


if [[ $(hostname||true) == "COMP-CF9QJYPYXL" ]]
then
  source "$WEASEL_RC/local.sh"
fi
