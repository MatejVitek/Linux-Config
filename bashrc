	# Command history size
HISTSIZE=5000
HISTFILESIZE=10000

# Aliases
alias ds="ssh DeathStar"
alias dingo="ssh dingo"
alias zvonko="ssh zvonko"
alias python=python3
alias bgmatlab="bgrun matlab -desktop"

bgrun () {
	nohup "$@" &>/dev/null &
}

diffdir () {
	if [ $# -ge 3 ]; then
		tree "$1" | sed 's/\.[^.]*$//' >tree1 && tree "$2" | sed 's/\.[^.]*$//' >tree2 && diff ./tree1 ./tree2; rm ./tree1 ./tree2
	else
		tree "$1" >tree1 && tree "$2" >tree2 && diff ./tree1 ./tree2; rm ./tree1 ./tree2
	fi
}
