export UNITEC_MULTICAST_INTERFACE="en0"
export UNITEC_MULTICAST_ADDRESS="224.0.0.249"
export UNITEC_PROJ_DIR="$GOPATH/src/github.com/develersrl/unitec-sw"
export SYSLOG_SERVER="127.0.0.1:5555"
ulimit -S -n 2048
alias swissbench="$UNITEC_PROJ_DIR/script/swissbench"
alias apiclient="$UNITEC_PROJ_DIR/sim/apiclient/apiclient"
alias encoder="$UNITEC_PROJ_DIR/sim/encoder/encoder"
alias release="$UNITEC_PROJ_DIR/tools/release/release"
alias deployall="swissbench --dbio-deploy --dbcn-deploy"
alias deploydbio="swissbench --dbio-deploy"
alias deploydbcn="swissbench --dbcn-deploy"
alias pingall="ping dbcn && ping dbio1 && ping dbio2 && ping dbio"
alias logdbio="export CURRENTLOG=\"../iod_$(date +%s).log\" && ssh root@172.25.2.1 journalctl -f -u iod | tee $CURRENTLOG && glogg $CURRENTLOG"

dbio1="172.25.2.1"
dbio2="172.25.3.1"
dbio3="172.25.4.1"
dbcn="172.25.100.1"

# Enable additional loopback addresses required for tests
utec_usage='
Usage: utec cmd

  cmd:
    - archive: create archive of the current HEAD as zip file
    - cd: cd to unitec project folder
    - ci: open ci link if available
    - l, loopback: enable loopback ips required for tests
    - m, metrics: Open metrics and copy to clipboard markdown useful for posting them somewhere (requires passing the from string as first argument)
    - pr: copy to clipboard the full pr template description with checked boxes
    - s, setup: do everything
    - h, help: print usage
    - logs: print logs and store to file
    - hosts: setup hosts for either: banchino,jolly
    - trace: get 30 second trace from provided ip and open in browser
    - cpu: get 30 second cpu profile from provided ip and open in browser
    - heap: get 30 seconds heap profile from provided ip and open in browser
    - tidy: tidy up code by running gofmt, goimports on files that have changed and golint and go vet an the whole project
    - v, validation: run validation program with provided options
    - fake: checkout HEAD in temporary fake gopath

If no cmd is provided the default cmd is cd
'

utec_fake() {
  FAKEGOPATH=/tmp/fake
  # The second argument is optional and is the commit hash/branch
  HASH=$1
  UNITEC_PROJ_DIR=$FAKEGOPATH/src/github.com/develersrl/unitec-sw
  if [[ "$HASH" == "" ]]; then
    HASH="HEAD"
  fi
  
  # Remove previous fake gopath
  rm -rf $FAKEGOPATH
  # Create fake gopath
  mkdir -p $UNITEC_PROJ_DIR
  export GOPATH=$FAKEGOPATH
  echo Created fake $GOPATH at $FAKEGOPATH

  # Get rid of previously created worktrees that have been deleted
  git worktree prune

  # Checkout $HASH inside the fake gopath
  git worktree add $UNITEC_PROJ_DIR $HASH

  cd $UNITEC_PROJ_DIR
  echo Checked-out $HASH at $UNITEC_PROJ_DIR
  echo Done.
}

utec_cd() {
  echo "Moving to directory ${blue}\$GOPATH/src/github.com/develersrl/unitec-sw${reset}"
  cd /Users/gmassi/develop/go/src/github.com/develersrl/unitec-sw
}

utec_ci() {
  kind=$1

  # log all available links if no type is given
  if [[ $kind == "" ]]; then
    hub ci-status -v | grep http
    return 0
  fi

  link=$(hub ci-status -v | grep "$kind" | awk '{print $4}')
  if [[ $link == http* ]]; then
    chrome $link
  else
    echo Link not found
  fi
}

utec_loopback() {
  echo "Adding ${green}loopack${reset} aliases: ${blue}127.0.0.1${reset}, ${blue}127.0.0.2${reset}, ${blue}127.0.0.3${reset}, ${blue}127.0.0.4${reset}, ${blue}127.0.1.1${reset}, ${blue}127.0.2.1${reset}, ${blue}127.0.3.1${reset}, ${blue}127.0.4.1${reset}"
  sudo ifconfig lo0 alias 127.0.0.1 up
  sudo ifconfig lo0 alias 127.0.0.2 up
  sudo ifconfig lo0 alias 127.0.0.3 up
  sudo ifconfig lo0 alias 127.0.0.4 up

  sudo ifconfig lo0 alias 127.0.1.1 up
  sudo ifconfig lo0 alias 127.0.2.1 up
  sudo ifconfig lo0 alias 127.0.3.1 up
  sudo ifconfig lo0 alias 127.0.4.1 up
}

utec_log() {
  service=""
  case "$1" in
  dbcn)
    service="cnd"
    ;;
  dbio1 | dbio2 | dbio3)
    service="iod"
    ;;
  esac
  mkdir -p /tmp/unitec-logs
  ssh root@$1 journalctl -f -u $service | tee /tmp/unitec-logs/boot-$1.logs
}

utec_setdate() {
  tstamp=$(date '+%s')
  mydate="$(date -u +"%d/%m/%Y %H:%M:%S +00:00" -d "@$tstamp")"
  echo calling apiclient -a dbcn setdatetime "${mydate}" 172.25.2.1:40001 172.25.3.1:40001 172.25.4.1:40001
  ./apiclient -a dbcn setdatetime "${mydate}" 172.25.2.1:40001 172.25.3.1:40001 172.25.4.1:40001
}

utec_route() {
  echo "Enabling multicast ips 224.0.0.249, 224.0.0.250 on $UNITEC_MULTICAST_INTERFACE"
  sudo route -v delete -inet 224.0.0.249 >/dev/null 2>&1
  sudo route -v delete -inet 224.0.0.250 >/dev/null 2>&1
  sudo route -nv add -net 224.0.0.249 -interface $UNITEC_MULTICAST_INTERFACE >/dev/null 2>&1
  sudo route -nv add -net 224.0.0.250 -interface $UNITEC_MULTICAST_INTERFACE >/dev/null 2>&1
}

utec_tidy() {
  gochecks || echo "${red}Checks failed${reset} (see output above)"
}

gochecks() {
  echo "Running ${green}gofmt${reset} on ${yellow}changed files${reset}..."
  echo $(git diff --cached --name-only --diff-filter=ACM | grep .go) | xargs gofmt -w -l || return 1
  echo "Running ${green}goimports${reset} on ${yellow}changed files${reset}..."
  echo $(git diff --cached --name-only --diff-filter=ACM | grep .go) | xargs goimports -w -l -local github.com/develersrl/unitec-sw || return 1
  echo "Running ${green}golint${reset} on ${yellow}whole project${reset}..."
  golint -set_exit_status $(go list ./...) || return 1
  echo "Running ${green}go vet${reset} on ${yellow}whole project${reset}..."
  go vet ./... || return 1
}

utec_hosts() {
  unset_hosts
  case "$1" in
  banchino)
    set_hosts_banchino
    ;;
  jolly)
    set_hosts_jolly
    ;;
  cherry)
    set_hosts_cherry
    ;;
  *)
    set_hosts_banchino
    ;;
  esac
}

unset_hosts() {
  sudo txeh remove host banchino dbcn sipu sipu1 dbio1 dbio2 dbio3
}

set_hosts_banchino() {
  echo "Setting up hosts for ${blue}banchino${reset}"

  dbio1="172.25.2.1"
  dbio2="172.25.3.1"
  dbio3="172.25.4.1"
  dbcn="172.25.100.1"

  sudo txeh add 172.25.100.1 dbcn
  sudo txeh add 172.25.100.2 sipu
  sudo txeh add 172.25.100.2 banchino
  sudo txeh add 172.25.2.1 dbio1
  sudo txeh add 172.25.3.1 dbio2
  sudo txeh add 172.25.4.1 dbio3
}

set_hosts_jolly() {
  echo "Setting up hosts for ${blue}jolly${reset}"

  dbio1="172.25.1,1"
  dbio2="172.25.1.2"
  dbio3=""
  dbcn="172.25.100.1"

  sudo txeh add 172.25.100.1 dbcn
  sudo txeh add 172.25.99.102 sipu
  sudo txeh add 172.25.1.1 dbio1
  sudo txeh add 172.25.1.2 dbio2
}

set_hosts_cherry() {
  echo "Setting up hosts for ${blue}cherry${reset}"

  dbio1="172.25.1,1"
  dbio2="172.25.1.2"
  dbio3=""
  dbcn="172.25.100.1"

  sudo txeh add 172.25.100.1 dbcn
  sudo txeh add 172.25.99.21 sipu1
  sudo txeh add 172.25.99.22 sipu2
  sudo txeh add 172.25.1.1 dbio1
  sudo txeh add 172.25.1.2 dbio2
}

utec_archive() {
  rm -f /tmp/unitec-sw.zip && git archive -o /tmp/unitec-sw.zip HEAD
}

utec_deploy() {
  DEPLOYDIR=$1
  if [[ "$DEPLOYDIR" == "" ]]; then
    echo "${red}Please provide deploy dir path${reset}"
    return 1
  fi

  echo "Deploying content from ${green}$DEPLOYDIR${reset}"

  echo "Deploying to ${green}$dbcn${reset}"
  $DEPLOYDIR/sysupdate-darwin -image-archive $DEPLOYDIR/images.zip $dbcn
  echo "Deploying to ${green}$dbio3${reset}"
  $DEPLOYDIR/sysupdate-darwin -image-archive $DEPLOYDIR/images.zip $dbio3
  echo "Deploying to ${green}$dbio2${reset}"
  $DEPLOYDIR/sysupdate-darwin -image-archive $DEPLOYDIR/images.zip $dbio2
  echo "Deploying to ${green}$dbio1${reset}"
  $DEPLOYDIR/sysupdate-darwin -image-archive $DEPLOYDIR/images.zip $dbio1
  echo "Enabling ${green}node_exporter${reset} service on all boards"
  swissbench --dbio-enable-node --dbcn-enable-node
}

utec_multicastcheck() {
  echo "Running test ${blue}TestMulticastOK${reset}"
  go test -test.run ^TestMulticastOK$ github.com/develersrl/unitec-sw/pkg/encoder >/dev/null 2>&1 || echo "Warning: multicast not working (UNITEC_MULTICAST_INTERFACE=$UNITEC_MULTICAST_INTERFACE)"
}

utec_validation() {
  lastDir="$(pwd)"
  echo "Running validation with options: ${blue}$@${reset}"
  cd $UNITEC_PROJ_DIR
  make debug
  cd validation
  go run validation.go --local-syslog="$SYSLOG_SERVER" $@
  cd $lastDir
}

utec_metrics() {
  if [ -z "$1" ]; then
    echo 'Please provide from string (e.g. "from=1565253180000&to=1565253780000")'
    return
  fi

  baseURL="https://unitec-mon.develer.net"

  echo "metrics with $1"

  from=$1

  metrics_addr="$baseURL:3000/d/P34vuzbmd/classification?orgId=1&$from"
  procfs_dbcn_addr="$baseURL:3000/d/4AuKeWxiz/procfs?orgId=1&$from&refresh=5s&var-job=prometheus&var-node=172.25.100.1&var-port=9100"
  procfs_dbio1_addr="$baseURL:3000/d/4AuKeWxiz/procfs?orgId=1&$from&refresh=5s&var-job=prometheus&var-node=172.25.2.1&var-port=9100"
  procfs_dbio2_addr="$baseURL:3000/d/4AuKeWxiz/procfs?orgId=1&$from&refresh=5s&var-job=prometheus&var-node=172.25.3.1&var-port=9100"
  procfs_dbio3_addr="$baseURL:3000/d/4AuKeWxiz/procfs?orgId=1&$from&refresh=5s&var-job=prometheus&var-node=172.25.4.1&var-port=9100"
  gometrics_addr="$baseURL:3000/d/ypFZFgvmz/go-metrics?orgId=1&$from&var-instance=All&var-interval=1m"

  echo "
- [metrics]($metrics_addr)
- procfs:
  - [dbcn]($procfs_dbcn_addr)
  - [dbio1]($procfs_dbio1_addr)
  - [dbio2]($procfs_dbio2_addr)
  - [dbio3]($procfs_dbio3_addr)
- [go-metrics]($gometrics_addr)
  " | toclip
}

utec_pr() {
  echo "## Pull request checklist

Before submitting a pull request,
please verify the following checklist:

### General

- [x] This PR has a description or the Trello card is linked.
- [x] This PR is rebased on current master branch.
- [x] Commits are well squashed (there are no fixup commits).

### Code

- [x] The code respects the specifications of the related Trello card.
- [x] There is no duplicate code.
- [x] Functions are not too big.
- [x] There are no global variables.
- [x] There is no commented out code.
- [x] Current code is refactored to match a new API or modifications.
- [x] Goroutines are properly stopped.
- [x] Error conditions are all logged.
- [x] Allocations don't affect the overall performances.
- [x] Atomic values are used in place of mutexes, when possibile.

### Documentation

- [x] An ADR is added in case of architectural decisions.
- [x] Public API is clear and well documented.
- [x] Thread safe functions are stated as such.
- [x] Function documentation is added or updated.
- [x] Obscure code snippets are explained.
- [x] The \`config_sample.toml\` and \`rule_sample.toml\` files are updated if a configuration parameter is added or removed.
- [x] The \`config_sample.toml\` and \`rule_sample.toml\` documentation is up to date.
- [x] The external documentation is updated.

### Test

- [x] The code respects the validations tests of the related Trello card.
- [x] The added functionalities are tested.
- [x] Mocks are used for functions that are using the hardware or accessing the network.
- [x] The \`foreman\` simulation works as expected." | toclip
  echo "Checked pr template ${green}copied${reset} to clipboard"
}

utec_trace() {
  TRACEFILE="/tmp/trace_$1_$(date +%s).out"
  echo "Getting trace from $green$1$reset (saving as $blue$TRACEFILE$reset)..."
  curl -s http://$1/debug/pprof/trace?seconds=30 >"$TRACEFILE"
  echo "Running ${yellow}go tool trace -http=:6060 $TRACEFILE${reset}"
  go tool trace -http=:6060 "$TRACEFILE"
}

utec_cpu() {
  CPUFILE="/tmp/cpu_$1_$(date +%s).out"
  echo "Getting cpu profile from $green$1$reset (saving as $blue$CPUFILE$reset)..."
  curl -s http://$1/debug/pprof/profile?seconds=30 >"$CPUFILE"
  echo "Running ${yellow}go tool pprof -http=:6060 $CPUFILE${reset}"
  go tool pprof -http=:6060 "$CPUFILE"
}

utec_heap() {
  HEAPFILE="/tmp/heap_$1_$(date +%s).out"
  echo "Getting heap profile from $green$1$reset (saving as $blue$HEAPFILE$reset)..."
  curl -s http://$1/debug/pprof/profile?seconds=30 >"$HEAPFILE"
  echo "Running ${yellow}go tool pprof -http=:6060 $HEAPFILE${reset}"
  go tool pprof -http=:6061 "$HEAPFILE" &
  chrome http://localhost:6061
  wait
}

utec_help() {
  echo "$utec_usage"
}

utec() {
  cmd=$1
  # If no cmd is provided, then
  if [[ -z "$1" ]]; then
    cmd="cd"
  fi

  if [[ "$cmd" == "" ]]; then
    cmd="cd"
  fi

  case "$cmd" in

  archive)
    utec_archive
    ;;

  cd)
    utec_cd
    ;;
  ci)
    shift
    utec_ci $@
    ;;

  fake)
    shift
    utec_fake $@
    ;;

  l | loopback)
    utec_loopback
    ;;

  m | metrics)
    utec_metrics $2
    ;;

  hosts)
    utec_hosts $2
    ;;

  check)
    utec_multicastcheck
    ;;

  pr)
    utec_pr
    ;;

  d | deploy)
    utec_deploy $2
    ;;

  s | setup)
    utec_cd
    utec_route
    utec_loopback
    utec_multicastcheck
    ;;

  v | validation)
    shift
    utec_validation $@
    ;;

  cpu)
    shift
    utec_cpu $@
    ;;

  heap)
    shift
    utec_heap $@
    ;;

  trace)
    shift
    utec_trace $@
    ;;

  tidy)
    shift
    utec_tidy $@
    ;;

  h | help)
    utec_help
    ;;

  *)
    utec_help
    ;;
  esac
}
