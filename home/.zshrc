# Plain zsh config - replaces the home-manager generated ~/.zshrc.
# PATH (brew, ~/.local/bin, orbstack) is set in ~/.zprofile.

typeset -U path fpath

export EDITOR="nvim"

HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
setopt NO_APPEND_HISTORY NO_EXTENDED_HISTORY NO_HIST_EXPIRE_DUPS_FIRST
setopt NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS NO_HIST_SAVE_NO_DUPS

autoload -U compinit && compinit

# ghost text from history
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history)
bindkey '^f' autosuggest-accept

alias ..='cd ..'
alias add='git add .'
alias cc='claude --dangerously-skip-permissions'
alias co='codex --full-auto'
alias gco='git checkout'
alias m='git switch main'
alias pull='git pull'
alias push='git push'

if [[ $TERM != "dumb" ]]; then
  eval "$(starship init zsh)"
fi

# commands turn green when valid - must be sourced last
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
