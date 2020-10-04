# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

###################################################################################################
# Environment Variables
###################################################################################################

export GOPATH=/home/gianni/dev/go
export GOBIN=/home/gianni/dev/go/bin
export PATH="$GOBIN:$PATH"

###################################################################################################
# Colours
###################################################################################################

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)

###################################################################################################
# Functions
###################################################################################################

# Check who ìs listening on port that matches the provided pattern
listening() {
    if [ $# -eq 0 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

# gochecks runs go imports, goftm, go lint and go vet on the current projec
gochecks() {
    echo "Running ${green}gofmt${reset} on ${yellow}changed files${reset}..."
    echo $(git diff --cached --name-only --diff-filter=ACM | grep .go) | xargs go fmt || return 1
    echo "Running ${green}goimports${reset} on ${yellow}changed files${reset}..."
    echo $(git diff --cached --name-only --diff-filter=ACM | grep .go) | xargs goimports -w -l -local github.com/develersrl/unitec-sw || return 1
    echo "Running ${green}golint${reset} on ${yellow}whole project${reset}..."
    golint -set_exit_status $(go list ./...) || return 1
    echo "Running ${green}go vet${reset} on ${yellow}whole project${reset}..."
    go vet ./... || return 1
}

###################################################################################################
# Aliases
###################################################################################################

# tmux aliases
alias tmux='tmux -u' # to make tmux understands that we want utf8...
alias tmat='tmux attach-session -t'
alias tmcs='tmux choose-session'
alias tmls='tmux list-sessions'
alias tmns='tmux new-session -s'

# cd aliases
alias cd='cd -P'
alias cd..='cd ../'
alias cd...='cd ../../'
alias cd....='cd ../../../'

# aliases for cding
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# Copy to clipboard
# Alias for piping to clipboard
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    alias toclip='xclip -sel clip && echo "${red}Copied to clipboard${reset}"'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    alias toclip='pbcopy'
fi

# Common mispellings
alias pign="ping"

## Quick Access
alias editme='code $HOME/dotfiles/'
alias reloadme='source $HOME/.bashrc'
alias q="exit"

###################################################################################################
# Git stuff
###################################################################################################

# gl - One-line git log of n lines (default is full log)
gl() {
    if [ -z "$1" ]; then
        git log --oneline
    else
        echo "${blue}Logging $1 commits...${reset}" && git log --oneline -n $@
    fi
}

# Super-fast access git commands via single/couple letter aliases
# Similar to git-extras but faster and more custom

# GIT STATUS
alias s='echo "${red}Status...${reset}" && git status'

# GIT ADD
alias a='echo "${red}Adding...${reset}" && git add'
# Only add files if no conflict are detected by looking on modified files for <<<<<<<
alias aa='if [ $(git diff --name-only | uniq | xargs grep -Hn "<<<<<<<" | tee >(wc -l)) -eq 0 ]; then a_nocheck; else echo "${red}Conflicting files, could not add.${reset}"; fi'
alias a_nocheck='echo "${red}Adding modified files...${reset}" && git add -uv'

# GIT COMMIT
alias c='echo "${red}Committing...${reset}" && git commit'
alias ano='echo "${red}Amending commit with no message edit...${reset}" && git commit --amend --no-edit'

# GIT BRANCH
alias b='git branch'

# GIT DIFF
alias d='echo "${red}Diff...${reset}" && git diff'
alias dc='echo "${red}Diff cached...${reset}" && git diff --cached'

# GIT PUSH
alias pf='echo "${red}Force pushing with lease...${reset}" && git push --force-with-lease'
alias p='echo "${green}Pushing...${reset}" && git push'

# GIT PULL
alias pl='echo "${green}Pulling (fast-forward)...${reset}" && git pull --ff-only'

# GIT CHECKOUT
alias ck='echo "${green}Checking out branch $1...${reset}" && git checkout $1'
alias ckb='echo "${green}Creating and checking out branch $1...${reset}" && git checkout -b $1'

# GIT FETCH
alias gf='echo "${green}Fetching...${reset}" && git fetch -tpa'

# GIT RESET
alias gr='echo "${green}Resetting${reset}" && git reset'
alias gr1='gr HEAD^'
alias gr2='gr HEAD^^'
alias gr3='gr HEAD^^^'

alias grh='echo "${red}Resetting with --hard${reset}" && git reset --hard'
alias grh1='grh HEAD^'
alias grh2='grh HEAD^^'
alias grh3='grh HEAD^^^'

# GIT OTHER
alias sub='echo "${green}Updating submodule...${reset}" && git submodule update'
alias rr='echo "${green}Continuing rebase...${reset}" && git rebase --continue'
alias dangit="git fsck --lost-found | grep 'dangling commit' | cut -d' ' -f 3 | xargs -I '{}' git --no-pager show --stat '{}'"
alias cleanb='echo "Cleaning ${yellow}gone${reset} branches (dry run)" && git branch --merged | grep -v "\*" | grep -v "master" | grep -v "develop" | grep -v "staging" | xargs -n 1 echo'
alias cleand='echo "Cleaning ${yellow}gone${reset} branches" && git branch --merged | grep -v "\*" | grep -v "master" | grep -v "develop" | grep -v "staging" | xargs -n 1 git branch -d'

###################################################################################################
# History
###################################################################################################

# Share history between different terminals
# The 3 next commands are taken from https://unix.stackexchange.com/questions/1288

# After each command, append to the history file and reread it
PROMPT_COMMAND="history -a; history -c; history -r;"

HISTCONTROL='ignoredups:erasedups'

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000

###################################################################################################
# Miscellanous stuff
###################################################################################################

# if fzf is installed, load key bindings and bash completion scripts
# see https://github.com/junegunn/fzf
if [ -f "/usr/local/bin/fzf" ]; then
    # fzf.bash is autogenerated during fzf installation
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

# Command Prompt
export GBT_CAR_DIR_DEPTH='2'   # Display only last 2 elements of the path
export GBT_CAR_DIR_BG='yellow' # Set the background color of the `Dir` car to light yellow
export GBT_CAR_DIR_FG='black'  # Set the foreground color of the `Dir` car to black
export GBT_CARS='Status,Dir,Sign'
PS1='$(gbt $?)'

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Manage go version with gvm
[[ -s "/home/gianni/.gvm/scripts/gvm" ]] && source "/home/gianni/.gvm/scripts/gvm"
gvm use go1.15.2 >/dev/null
