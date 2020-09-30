################################################################################
# Env

# Lang
export LC_ALL=en_GB.UTF-8

#Go
alias go113=$HOME/goroots/go1.13.1/bin/go
alias go114=$HOME/goroots/go1.14.4/bin/go
alias gotip=$HOME/goroots/gotip/bin/go

export GOROOT_BOOTSTRAP=$HOME/goroots/go1.14.1/bin/go
export GOPATH=$HOME/develop/go
export GOBIN=$GOPATH/bin/

## current go version
export PATH="$PATH:$HOME/goroots/go1.14.4/bin"

export SSH_KEYS="$HOME/.ssh/id_bitbucket_rsa $HOME/.ssh/id_develer_rsa $HOME/.ssh/id_digitalocean_rsa $HOME/.ssh/id_do_rsa $HOME/.ssh/id_hostgator_rsa"

# QT
export PATH=$PATH:$HOME/Qt/5.10.1/clang_64/bin
export PATH="/usr/local/opt/qt/bin:$PATH"

# Android
export ANDROID_HOME="/Users/gmassi/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools/"

## Flutter
export PATH="$PATH:/Users/gmassi/develop/tools/flutter/bin"

# Yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# GStreamer tools
# export PATH="$PATH:/Library/Frameworks/GStreamer.framework/Commands/"

# Gnu tools
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"

## Google sheet API
export GOOGLESHEET_CLIENTID="677286607210-h459kbd5nnafpnb52kqa1s469ik63hlv.apps.googleusercontent.com"
export GOOGLESHEET_CLIENTSECRET="Lvm9QwSMnxKgb3No9quTl65T"

## COVID
export COVID_GOOGLESHEET="1ScZ1Zg7dIWw1jGsRbljUhcfWERpcVCOVCCByiFBuFLE"

## Goreleaser
export GITHUB_TOKEN=8d5f8796da042846978e375752224323f5ace2ed

# Remove zsh warning
export BASH_SILENCE_DEPRECATION_WARNING=1

# # added by Anaconda3 2019.10 installer
# # >>> conda init >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$(CONDA_REPORT_ERRORS=false '/opt/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     \eval "$__conda_setup"
# else
#     if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/opt/anaconda3/etc/profile.d/conda.sh"
#         CONDA_CHANGEPS1=false conda activate base
#     else
#         \export PATH="/opt/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda init <<<

################################################################################
# Aliases
alias gogm='cd ~/develop/go/src/github.com/giannimassi'
alias devg='cd ~/develop/giannimassi'
alias codicefiscale='echo MSSGNN91R05G491Y | toclip'
alias astronomer="env GITHUB_TOKEN=8930d500f45921e69efc8be5511b2215ebfcf085 astronomer --cachedir /var/tmp/astronomer-cache"
alias dockerlinux="docker run \
  --name ubuntu \
  -e HOST_IP=$(ifconfig en0 | awk '/ *inet /{print $2}') \
  -v /Users/gmassi/develop:/develop \
  -t -i \
  ubuntu /bin/bash"

################################################################################
# Apps
alias chrome='echo "${red}Opening with Chrome...${reset}" && open -a "Google Chrome" ' # Open with chrome
alias glogg=/Applications/glogg.app/Contents/MacOS/glogg

################################################################################
## Functions

# Enable static ip on usb adapter (use 172.16.20.254 if not provided)
usb_static() {
  ip=$1
  if [ -z "$1" ]; then
    ip="172.25.254.254"
  fi

  echo "Enabling static ip ${yellow}${ip}${reset} on ${blue}usb adapter${reset}..."
  network_service_enabled usb-dhcp && networksetup -setnetworkserviceenabled usb-dhcp off
  network_service_enabled usb-static-ip || networksetup -setnetworkserviceenabled usb-static-ip on &&
    networksetup -setmanual usb-static-ip $ip 255.255.0.0
}

usb_dhcp() {
  echo "Enabling dhcp on ${blue}usb adapter${reset}..."
  network_service_enabled usb-dhcp || networksetup -setnetworkserviceenabled usb-static-ip off && networksetup -setnetworkserviceenabled usb-dhcp on
}

network_service_enabled() {
  if [[ $(networksetup -getnetworkserviceenabled $1) == "Enabled" ]]; then
    return 0
  else
    return 1
  fi
}

# Uncolorize file
function nocolor() {
  cat $1 | sed -r "s/[[:cntrl:]]\[[0-9]{1,3}m//g" >nocolor_$1
}

# Create new go project
function newgopkg() {
  cd ~/develop/giannimassi/
  mkdir $1
  cd $1
  echo "package main
  
  func main() {}
" >main.go
  go mod init github.com/giannimassi/$1
  git init
}

enit() {
  open "https://translate.google.it/#en/it/$(urlencode $@)"
}
iten() {
  open "https://translate.google.it/#it/en/$(urlencode $@)"
}

urlencode() {
  local length="${#1}"
  for ((i = 0; i < length; i++)); do
    local c="${1:$i:1}"
    case $c in
    [a-zA-Z0-9.~_-]) printf "$c" ;;
    *) printf '%s' "$c" | xxd -p -c1 |
      while read c; do printf '%%%s' "$c"; done ;;
    esac
  done
}

urldecode() {
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//"%"/\\x}"
}

cistatus() {
  hub ci-status -f "%S, %t|" |
    gsed -r '
    s/failure, /#[fg=red]/g;
    s/success, /#[fg=green]/g;
    s/pending, /#[fg=yellow]/g;
    s/\|$//;
    s/\|/#[fg=white]|/g;
    s/-tests//g;'
}

pingtest() {
  count=$1
  addr=$2
  logname="ping-c$count-addr$addr-"$(date -u +"%Y%m%dT%H%M%SZ").log
  echo "Ping test (with ping -c=$count $addr) log at $logname"
  ping -c $count $addr | tee $logname
  echo "Done. Log at $logname"
}

# gobench checks-out the provided commits, runs benchmarks for them and compares stats
gobench() {
  # Options (defaults)
  BASECOMMIT="0ca2821a"
  LASTCOMMIT="bb96039a"
  TESTCOUNT=10
  BENCHMARKPKG="github.com/develersrl/unitec-sw/pkg/tuttifrutti"
  BENCHMARKTEST="Serialize"

  if [[ "$1" != "" ]]; then
    BASECOMMIT=$(git rev-parse $1)
  fi

  if [[ "$2" != "" ]]; then
    LASTCOMMIT=$(git rev-parse $2)
  fi

  if [[ "$3" != "" ]]; then
    TESTCOUNT=$3
  fi

  # Other variables
  CURRENTBRANCH=$(git rev-parse --abbrev-ref HEAD)
  BASEBENCHFILE="benchmark-$BASECOMMIT.txt"
  LASTBENCHFILE="last-$LASTCOMMIT.txt"
  rm -f $BASEBENCHFILE $LASTBENCHFILE
  echo "${yellow}Benchmarks${reset} (${blue}$BASECOMMIT${reset} vs ${blue}$LASTCOMMIT${reset}) for pkg ${blue}\"$BENCHMARKPKG\"${reset}, test ${blue}\"$BENCHMARKTEST\"${reset}, with count=${blue}$TESTCOUNT${reset}"
  echo "Running ${yellow}benchmark${reset} for ${blue}$BASECOMMIT${reset} (old)"
  git checkout -q $BASECOMMIT
  go test -count=$TESTCOUNT $BENCHMARKPKG -test.benchmem=true -bench=$BENCHMARKTEST >>$BASEBENCHFILE

  echo "Running ${yellow}benchmark${reset} for ${blue}$LASTCOMMIT${reset} (new)"
  git checkout -q $LASTCOMMIT
  go test -count=$TESTCOUNT $BENCHMARKPKG -test.benchmem=true -bench=$BENCHMARKTEST >>$LASTBENCHFILE

  git checkout -q $CURRENTBRANCH
  benchstat $BASEBENCHFILE $LASTBENCHFILE
}
