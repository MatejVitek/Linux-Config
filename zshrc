# zsh ignores .inputrc so we need to match that configuration here
# Initialise the completion system (if not already initialised elsewhere)
autoload -Uz compinit
compinit

# Make tab-completion case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Make TAB cycle through entries instead of listing them
zstyle ':completion:*' menu select
bindkey '^[[Z' reverse-menu-complete # Shift+Tab to cycle backward

# Arrow up/down autocompletes to history, rather than scrolling through history
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# More informative prompt
if [[ -n "$SSH_CONNECTION" ]]; then
    # Remote: user@host in green, full path in blue
    PROMPT='%F{green}%n@%m%f:%F{blue}%~%f %# '
else
    # Local: full path in blue only
    PROMPT='%F{blue}%~%f %# '
fi
