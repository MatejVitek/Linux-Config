#!/usr/bin/env bash

# Helper function to ask for confirmation
ask() {
	case "$2" in
	[Yy]*)
		DEFAULT=$(true)
		PROMPT="[Y]/N"
		;;
	[Nn]*)
		DEFAULT=$(false)
		PROMPT="Y/[N]"
		;;
	*)
		PROMPT="Y/N"
		;;
	esac

	while true; do
		read -p "$1 ($PROMPT) " yn
		case $yn in
		[Yy]*)
			return $(true)
			;;
		[Nn]*)
			return $(false)
			;;
		*)
			if [ "$DEFAULT" ]; then
				return $DEFAULT
			fi
			echo "Please answer yes or no."
			;;
		esac
	done
}

# Move directory to ~/.cfg (if you started inside the directory, the terminal will still say you're in the old directory name after the script finishes but actually it will be renamed)
cd $(dirname "${BASH_SOURCE[0]}")
pwd=$(pwd)
if [ ! "$pwd" -ef "$HOME/.cfg" ]; then
	echo "Renaming directory"
	cd ..
	mv "$pwd" "$HOME/.cfg"
fi
cd "$HOME"

# Copy defaults to local
[ -d .cfg/local ] || mkdir .cfg/local
for FILE in .cfg/default/*; do
	NAME=$(basename "$FILE")
	if [ ! -e ".cfg/local/$NAME" ]; then
		echo "Copying $NAME to local"
		cp "$FILE" ".cfg/local/$NAME"
	fi
done

# Set global permissions
echo "Setting permissions"
chmod -R 755 .cfg

# bashrc
# If bashrc isn't sourced yet in .bashrc, append line
if ! grep -q -F '.cfg/bashrc' .bashrc; then
	echo "Appending bashrc"
	echo '. "$HOME/.cfg/bashrc"' >> .bashrc
else
	echo "bashrc already found"
fi

# If .bash_profile doesn't exist but .profile does, rename it (since we never use sh as a login shell anyway)
if [ ! -e .bash_profile ] && [ -e .profile ]; then
	echo "Renaming .profile to .bash_profile"
	mv .profile .bash_profile
fi

# If profile isn't sourced yet in .bash_profile, append line (but currently doesn't exist so commented out)
#TODO: Create the file and add ssh-agent code to it from https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login/18915067#18915067
#if ! grep -q -F '.cfg/profile' .bash_profile; then
#	echo "Appending profile"
#	echo '. "$HOME/.cfg/profile"' >> .bash_profile
#else
#	echo "profile already found"
#fi

# gitconfig
# Similar to bashrc
# If it doesn't exist, create it
[ -e .gitconfig ] || touch .gitconfig
# If including git doesn't happen yet in .gitconfig, add it
if [ ! -L .gitconfig ] && ! grep -q -F '.cfg/git' .gitconfig; then
	echo "Including shared git config"
	# If [include] not in .gitconfig yet, add it at the start
	newline=
	if ! grep -q -F '[include]' .gitconfig; then
		newline=\\\n
		if [ -s .gitconfig ]; then
			sed -i '1i\[include]' .gitconfig
		else
			echo "[include]" >> .gitconfig
		fi
	fi
	# https://fabianlee.org/2018/10/28/linux-using-sed-to-insert-lines-before-or-after-a-match/
	sed -i "/^\[include\]/a \\\\tpath = ~\/.cfg\/git${newline}" .gitconfig
else
	echo ".gitconfig already linked or included"
fi

# WSL Stuff
if uname -a | egrep -i "(microsoft|wsl|windows)" &>/dev/null; then
	# Link WSL SSH Agent to npiperelay.exe
	if [ -L .wsl-ssh-agent ]; then
		echo "WSL SSH Agent already linked"
	else
		[ -e .wsl-ssh-agent ] && ask ".wsl-ssh-agent already exists but is not a symbolic link. Remove it?" Y && rm .wsl-ssh-agent
		if [ ! -e .wsl-ssh-agent ]; then
			FILE="/mnt/c/Program Files/WSL SSH Agent/npiperelay.exe"
			[ -e "$FILE" ] || FILE="${FILE/"Program Files"/"Program Files (x86)"}"
			[ -e "$FILE" ] || read -p "Path to npiperelay.exe (don't use quotes; leave empty to not set up WSL SSH Agent): " FILE
			if [ -e "$FILE" ]; then
				echo "Linking WSL SSH Agent to $FILE"
				ln -s "$FILE" .wsl-ssh-agent
			fi
		fi
	fi
fi

# tmux
# Link .tmux.conf to tmux if possible
if [ -L .tmux.conf ]; then
	echo ".tmux.conf already linked"
elif [ -f .tmux.conf ]; then
	echo "Could not link .tmux.conf->.cfg/tmux, because .tmux.conf already exists. Please merge manually."
else
	echo "Linking tmux"
	ln -s .cfg/tmux .tmux.conf
fi

# .inputrc
# If it's a link, leave it alone
if [ -L .inputrc ]; then
	echo "inputrc already linked"
# If it's a normal file, follow procedure from gitconfig
elif [ -f .inputrc ]; then
	if ! grep -q -F '.cfg/inputrc' .inputrc; then
		echo "Appending inputrc"
		# Prepend instead of appending so the local configuration wins out
		if [ -s .inputrc ]; then
			sed -i '$include "$HOME/.cfg/inputrc"' .inputrc
		else
			echo '$include "$HOME/.cfg/inputrc"' >> .inputrc
		fi
	else
		echo "inputrc already found"
	fi
# Otherwise link it to inputrc
else
	echo "Linking inputrc"
	ln -s .cfg/inputrc .inputrc
fi

# If ~/.ssh doesn't exist yet, create it
if [ ! -d .ssh ]; then
	echo "Creating ~/.ssh directory"
	mkdir .ssh
fi
chmod 700 .ssh

# If ssh keys don't exist yet, generate them
if ! ls .ssh/id_* &>/dev/null; then
	if ask "SSH keys not found. Should I generate them?"; then
		ssh-keygen -o -a 100 -t ed25519
		chmod 644 .ssh/id_ed25519.pub
		chmod 600 .ssh/id_ed25519
	fi
fi

# For ssh, same as tmux above
if [ -L .ssh/config ]; then
	echo ".ssh/config already linked"
elif [ -f .ssh/config ]; then
	echo "Could not link .ssh/config->.cfg/ssh, because .ssh/config already exists. Please merge manually."
else
	echo "Linking ssh"
	ln -s ../.cfg/ssh .ssh/config
fi
chmod 700 .cfg/ssh

# For cssh, similar to ssh above but link whole directory
if [ -L .clusterssh ]; then
	echo ".clusterssh already linked"
elif [ -d .clusterssh ]; then
	echo "Could not link .clusterssh->.cfg/cssh, because .clusterssh already exists. Please merge manually."
else
	echo "Linking cssh"
	ln -s .cfg/cssh .clusterssh
fi

# localbashrc - same thing as bashrc
if ! grep -q -F '.cfg/local/bashrc' .bashrc; then
	echo "Appending local bashrc"
	echo '. "$HOME/.cfg/local/bashrc"' >> .bashrc
else
	echo "Local bashrc already found"
fi

# localprofile - same thing as bashrc
if ! grep -q -F '.cfg/local/profile' .bash_profile; then
	echo "Appending local profile"
	echo '. "$HOME/.cfg/local/profile"' >> .bash_profile
else
	echo "Local profile already found"
fi

# Replace this repo's URL with the SSH version since we have SSH keys now
URL="$(git -C .cfg remote get-url origin)"
if [[ "$URL" == "https:"* ]]; then
	if ask "This repo currently uses HTTPS. Switch to SSH?" Y; then
		URL="${URL/https:\/\/github.com\//git@github.com:}"
		echo "Replacing remote URL with ${URL}, don't forget to upload your SSH key to your GitHub profile"
		git -C .cfg remote set-url origin "$URL"
	fi
fi
