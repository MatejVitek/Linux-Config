# Command history size
HISTSIZE=5000
HISTFILESIZE=10000

# Aliases
alias python=python3
alias pip=pip3
alias ds="ssh DeathStar"
alias dingo="ssh dingo"
alias panga="ssh panga"
alias palit="ssh palit"
alias zverina="ssh zverina"
alias zvonko="ssh zvonko"
alias newton="ssh newton"
alias lecun="ssh lecun"
alias bengio="ssh bengio"
alias sclera="ssh sclera"
alias dgx="ssh dgx"
alias vega="ssh vega"
alias cvega="ssh vegacpu"
alias gvega="ssh vegagpu"
alias bgmatlab="bgrun matlab -desktop"
alias tm="tmux new -A -s"
alias tma="tmux attach -t"
alias tmn="tmux new -s"
alias present="pdfpc -s"
alias nsmi="watch -d -n 0.5 -t nvidia-smi"

bgrun () {
	nohup "$@" &>/dev/null &
}

# This can't be an alias because arguments don't get parsed properly
matrun () {
	matlab -batch "$1"
}

diffdir () {
	if [ $# -ge 3 ]; then
		tree "$1" | sed 's/\.[^.]*$//' >tree1 && tree "$2" | sed 's/\.[^.]*$//' >tree2 && diff ./tree1 ./tree2; rm ./tree1 ./tree2
	else
		tree "$1" >tree1 && tree "$2" >tree2 && diff ./tree1 ./tree2; rm ./tree1 ./tree2
	fi
}

# Run this without .tex extension for file (otherwise bibtex doesn't work)
texcompile () {
	pdflatex "$1"
	bibtex "$1"
	pdflatex "$1"
	pdflatex "$1"
}

texclean () {
	arg="${1:-.}"
	exts="aux bbl blg brf idx ilg ind lof log lol lot out toc synctex.gz"

	if [ -d $arg ]; then
		for ext in $exts; do
			rm -f $arg/*.$ext
		done
	else
		for ext in $exts; do
			rm -f $arg.$ext
		done
	fi
}
