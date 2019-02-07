#!/bin/bash
cd ~

# Rename to .cfg
if [ -d linux-config ] then
	mv linux-config .cfg
fi

# Copy defaults to local
if [ ! -d .cfg/local ] then
	cp -r .cfg/default .cfg/local
fi

# If sourcing bashrc doesn't happen yet in .bashrc, append line
grep -q -F '.cfg/bashrc' .bashrc && echo bashrc already found || echo Appending bashrc && echo '. ~/.cfg/bashrc' >> .bashrc

# Similar for profile (but currently doesn't exist so commented out)
# grep -q -F '.cfg/profile' .profile && echo profile already found || echo Appending profile && echo '. $HOME/.cfg/profile' >> .profile

# Link .gitconfig to git
if [ ! -f .gitconfig ] then
	echo Linking git
	ln -s ~/.cfg/git .gitconfig
else
	echo Could not link .gitconfig->.cfg/git, please merge manually.
fi

# inputrc
if [ -f .inputrc ]
	# If it exists, follow procedure from bashrc
	grep -q -F '.cfg/inputrc' .inputrc && echo inputrc already found || echo Appending inputrc && echo '$include ~/.cfg/inputrc' >> .inputrc
else
	# Otherwise link it to inputrc
	echo Linking inputrc
	ln -s ~/.cfg/inputrc .inputrc
fi

# For ssh, same as git above
if [ ! -f .ssh/config ] then
	echo Linking ssh
	ln -s ~/.cfg/ssh ~/.ssh/config
else
	echo Could not link .ssh/config->.cfg/ssh, please merge manually.
fi

# localbashrc
grep -q -F '.cfg/local/bashrc' .bashrc && echo Local bashrc already found || echo Appending local bashrc && echo '. ~/.cfg/local/bashrc' >> .bashrc

#localprofile
grep -q -F '.cfg/local/profile' .profile && echo Local profile already found || echo Appending local profile && echo '. $HOME/.cfg/local/profile' >> .profile
