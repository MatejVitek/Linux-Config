#!/usr/bin/env bash

# Helper function to ask for confirmation
ask() {
	while true; do
		read -p "$1 (Y/N) " yn
		case $yn in
		[Yy]*)
			return $(true)
			;;
		[Nn]*)
			return $(false)
			;;
		*)
			echo "Please answer yes or no."
			;;
		esac
	done
}


# Move directory to ~/.cfg (if you started inside the directory, the terminal will still say you're in the old directory name after the script finishes but actually it will be renamed)
cd $(dirname "${BASH_SOURCE[0]}")
pwd=$(pwd)
if [ ! "$pwd" -ef ~/.cfg ]; then
	echo "Renaming directory"
	cd ..
	mv "$pwd" ~/.cfg
fi
cd ~

# Copy defaults to local
if [ ! -d .cfg/local ]; then
	echo "Copying defaults to local"
	cp -r .cfg/default .cfg/local
fi

# Set global permissions
echo "Setting permissions"
chmod -R 755 ~/.cfg

# bashrc
# If sourcing bashrc doesn't happen yet in .bashrc, append line
if ! grep -q -F '.cfg/bashrc' .bashrc; then
	echo "Appending bashrc"
	echo '. "$HOME/.cfg/bashrc"' >> .bashrc
else
	echo "bashrc already found"
fi

# Similar for profile (but currently doesn't exist so commented out)
#TODO: Create the file and add ssh-agent code to it from https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login/18915067#18915067

#if ! grep -q -F '.cfg/profile' .profile; then
#	echo "Appending profile"
#	echo '. "$HOME/.cfg/profile"' >> .profile
#else
#	echo "profile already found"
#fi

# gitconfig
# Similar to bashrc
# If it doesn't exist, create it
if [ ! -f .gitconfig ]; then
	touch .gitconfig
fi
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
	sed -i "/^\[include\]/a \\\\tpath = \"~\/.cfg\/git\"${newline}" .gitconfig
else
	echo ".gitconfig already linked or included"
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
if ! grep -q -F '.cfg/local/profile' .profile; then
	echo "Appending local profile"
	echo '. "$HOME/.cfg/local/profile"' >> .profile
else
	echo "Local profile already found"
fi

# Replace this repo's URL with the SSH version since we have SSH keys now
URL="$(git -C .cfg remote get-url origin)"
if [[ "$URL" == "https:"* ]]; then
	if ask "This repo currently uses HTTPS. Switch to SSH?"; then
		URL="${URL/https:\/\/github.com\//git@github.com:}"
		echo "Replacing remote URL with ${URL}, don't forget to upload your SSH key to your GitHub profile"
		git -C .cfg remote set-url origin "$URL"
	fi
fi
