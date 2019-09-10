# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private scripts dir if it exists
if [ -d "$HOME/scripts" ] ; then
    PATH="$PATH:$HOME/scripts"
fi

############################################################
# machine specific values that can't be included in dotfiles
# because they are specific to a machine
#
if [ -f "$HOME/.localbashrc" ]; then
    . "$HOME/.localbashrc"
fi

if [ -n "$NPM_PACKAGES" ]; then
    export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
    export PATH="$NPM_PACKAGES/bin:$PATH"

    # Unset manpath so we can inherit from /etc/manpath via the `manpath` command
    unset MANPATH
    export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"
fi

# If set and if it exists, add $HOME/.local/bin directory to the path
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# If set and if it exists, add LOCAL GO /bin directory to the path
if [ -n "$LOCALGOBIN" ]; then
    if [ -d "$LOCALGOBIN" ]; then
        export PATH="$LOCALGOBIN:$PATH"
    fi
fi

# If set and if it exists, use GOPATH and add $GOPATH/bin to the path
if [ -n "$GOPATH" ]; then
    if [ -d "$GOPATH" ]; then
        export PATH="$GOPATH:$PATH"
    fi
fi

export GIT_EDITOR=nvim