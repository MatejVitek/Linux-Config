# Add lines to ~/.bashrc:
# . ~/.cfg/bashrc
# . ~/.cfg/local (Only if local config exists)

# Command history size
HISTSIZE=5000
HISTFILESIZE=10000

# Aliases
alias ds="ssh DeathStar"
alias dingo="ssh dingo"
alias zvonko="ssh zvonko"
alias python=python3

bg () {
	"$@" &
	disown
}
