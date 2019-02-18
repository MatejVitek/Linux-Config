#!/bin/bash

# Move directory to ~/.cfg
cd $(dirname "${BASH_SOURCE[0]}")
pwd=$(pwd)
if [ ! "$pwd" -ef ~/.cfg ]; then
	echo "Renaming directory"
	cd ..
	cp -r "$pwd" ~/.cfg
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

# If sourcing bashrc doesn't happen yet in .bashrc, append line
if ! grep -q -F '.cfg/bashrc' .bashrc; then
	echo "Appending bashrc"
	echo '. "$HOME/.cfg/bashrc"' >> .bashrc
else
	echo "bashrc already found"
fi

# Similar for profile (but currently doesn't exist so commented out)
#if ! grep -q -F '.cfg/profile' .profile; then
#	echo "Appending profile"
#	echo '. "$HOME/.cfg/profile"' >> .profile
#else
#	echo "profile already found"
#fi

# .gitconfig
# If it's already a link, do nothing
if [ -L .gitconfig ]; then
	echo ".gitconfig already linked"
# If it's a normal file, report conflict
elif [ -f .gitconfig ]; then
	echo "Could not link .gitconfig->.cfg/git, because .gitconfig already exists. Please merge manually."
# Otherwise link it to git
else
	echo "Linking git"
	ln -s ~/.cfg/git .gitconfig
fi

# .inputrc
# If it's already a link, do nothing
if [ -L .inputrc ]; then
	echo "inputrc already linked"
# If it's a normal file, follow procedure from bashrc above
elif [ -f .inputrc ]; then
	if ! grep -q -F '.cfg/inputrc' .inputrc; then
		echo "Appending inputrc"
		# TODO: Prepend instead of appending
		echo '$include "$HOME/.cfg/inputrc"' >> .inputrc
	else
		echo "inputrc already found"
	fi
# Otherwise link it to inputrc
else
	echo "Linking inputrc"
	ln -s ~/.cfg/inputrc .inputrc
fi

# For ssh, same as git above
if [ -L .ssh/config ]; then
	echo ".ssh/config already linked"
elif [ -f .ssh/config ]; then
	echo "Could not link .ssh/config->.cfg/ssh, because .ssh/config already exists. Please merge manually."
else
	echo "Linking ssh"
	ln -s ~/.cfg/ssh .ssh/config
fi
# Stricter permissions
chmod 700 ~/.cfg/ssh

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

# If directory was copied, remove old one
if [ ! "$pwd" -ef ~/.cfg ]; then
	rm -rf "$pwd"
fi
