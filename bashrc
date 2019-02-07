# Append line to ~/.bashrc:
# . ~/.cfg/bashrc

# Command history size
HISTSIZE=5000
HISTFILESIZE=10000

# Aliases
alias ds="ssh DeathStar"
alias dingo="ssh dingo"
alias zvonko="ssh zvonko"
alias python=python3
alias bgmatlab="bgrun matlab -desktop"

bgrun () { nohup "$@" &>/dev/null & }
