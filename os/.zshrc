# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="af-magic"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    tmux
    alias-finder
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Run alias-finder automatically every time you input a command
ZSH_ALIAS_FINDER_AUTOMATIC=true

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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

autogit() {
    ~/.scripts/watch-and-commit.sh | xargs -I{} ~/.scripts/commit-all.sh {}
}

installautogit() {
    dir="${PWD}"

    name="$(echo "${dir}" | tr / .)"
    mkservice "$name.push" "~/.scripts/watch-and-commit.sh | xargs -I{}  ~/.scripts/commit-all.sh {}" "${dir}"

    # Do not remove second name assignment, it is mutated after mkservice cmd (don't know why)
    name="$(echo "${dir}" | tr / .)"
    mkcronservice "$name.pull" "git pull" "${dir}" 60
}

removeautogit() {
    dir="${PWD}"

    name=$(echo "${dir}" | tr / .)
    rmservice "${name}-push"

    name="$(echo "${dir}" | tr / .)"
    rmservice "${name}-pull"
}

rmservice() {
    name=$1
    plistPath="${HOME}/Library/LaunchAgents/${name}.plist"
    launchctl unload $plistPath
    rm $plistPath
    echo "Service ${name} uninstalled"
}

mkcronservice() {
    name=$1
    cmd=$2
    workingDir=$3
    seconds=$4

    plistPath="${HOME}/Library/LaunchAgents/${name}.plist"

    outLog="/tmp/${name}.out.log"
    errLog="/tmp/${name}.error.log"
    template="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC -//Apple Computer//DTD PLIST 1.0//EN http://www.apple.com/DTDs/PropertyList-1.0.dtd>
<plist version=\"1.0\">
<dict>
    <key>Label</key>
    <string>${name}</string>
    <key>ProgramArguments</key>
    <array>
        <string>sh</string>
        <string>-c</string>
        <string>${cmd}</string>
    </array>
    <key>KeepAlive</key>
    <true/>
    <key>WorkingDirectory</key>
    <string>${workingDir}</string>
    <key>StandardOutPath</key>
    <string>${outLog}</string>
    <key>StandardErrorPath</key>
    <string>${errLog}</string>
    <key>UserName</key>
	<string>gianni</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${PATH}</string>
    </dict>
    <key>StartInterval</key>
    <integer>${seconds}</integer>
</dict>
</plist>"

    echo $template >$plistPath
    launchctl load $plistPath

    echo "Cron Service ${name} installed ($plistPath)"
    echo "\tStdout Log: ${outLog}"
    echo "\tStderr Log: ${errLog}"
}

mkservice() {
    name=$1
    cmd=$2
    workingDir=$3

    plistPath="${HOME}/Library/LaunchAgents/${name}.plist"

    outLog="/tmp/${name}.out.log"
    errLog="/tmp/${name}.error.log"

    template="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC -//Apple Computer//DTD PLIST 1.0//EN http://www.apple.com/DTDs/PropertyList-1.0.dtd>
<plist version=\"1.0\">
<dict>
    <key>Label</key>
    <string>${name}</string>
    <key>ProgramArguments</key>
    <array>
        <string>sh</string>
        <string>-c</string>
        <string>${cmd}</string>
    </array>
    <key>KeepAlive</key>
    <true/>
    <key>WorkingDirectory</key>
    <string>${workingDir}</string>
    <key>StandardOutPath</key>
    <string>${outLog}</string>
    <key>StandardErrorPath</key>
    <string>${errLog}</string>
    <key>UserName</key>
	<string>gianni</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${PATH}</string>
    </dict>
</dict>
</plist>"

    echo $template >$plistPath
    launchctl load $plistPath

    echo "Service ${name} installed ($plistPath)"
    echo "\tStdout Log: ${outLog}"
    echo "\tStderr Log: ${errLog}"
}

alias fun='tmux new-session -A -s fun'
alias work='tmux new-session -A -s work'
alias dotfiles='tmux new-session -A -s dotfiles'
alias editme="code ~/dotfiles"
alias reloadme="source ~/.zshrc"

# cd aliases
alias cd='cd -P'
alias cd..='cd ../'
alias cd...='cd ../../'
alias cd....='cd ../../../'

# aliases for cding
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# quick and unorthodox, never more useful
alias q="exit"

###################################################################################################
# Environment Variables
###################################################################################################

# set options for less
export LESS='--quit-if-one-screen --ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-4'

export GOPATH=~/dev/go
export GOBIN=~/dev/go/bin
export PATH="$GOBIN:$PATH"

# Cargo
export CARGO_HOME=~/.cargo
export PATH="$CARGO_HOME/bin:$PATH"

# direnv hook
eval "$(direnv hook zsh)"

export EDITOR=vim

source ~/.private
source ~/.gvm/scripts/gvm