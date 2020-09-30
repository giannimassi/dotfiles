################################################################################
# GIT

# Setup Git bash completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# One-line git log of n lines (default is full log)
gl() {
  if [ -z "$1" ]; then
    git log --oneline
  else
    echo "${blue}Logging $1 commits...${reset}" && git log --oneline -n $@
  fi
}
ismac && __git_complete gl _git_log

# GIT STATUS
alias s='echo "${red}Status...${reset}" && git status'

# GIT ADD
alias a='echo "${red}Adding...${reset}" && git add'
ismac && __git_complete a _git_add
alias a_nocheck='echo "${red}Adding modified files...${reset}" && git add -uv'
# Only add files if no conflict are detected by looking on modified files for <<<<<<<
alias aa='if [$(git diff --name-only | uniq | xargs grep -Hn "<<<<<<<" | tee >(wc -l)) -gt 0 ]; then echo "${red}Conflicting files, could not add.${reset}"; else a_nocheck; fi'
# Extra: show conflicting files
alias cfl='if [$(find . | grep ".*\.qml\|.*\.qrc$" | xargs grep -Hn "<<<<<<<" | tee >(wc -l)) -gt 0 ]; then echo "${red}Conflicting files found${reset}"; else "${green}No conflicts found.${reset}"; fi;'

# GIT COMMIT
alias c='echo "${red}Committing...${reset}" && git commit'
ismac && __git_complete c _git_commit
alias ano='echo "${red}Amending commit with no message edit...${reset}" && git commit --amend --no-edit'
ismac && __git_complete ano _git_commit

# GIT BRANCH
alias b='git branch'
ismac && __git_complete b _git_branch

# GIT DIFF
alias d='echo "${red}Diff...${reset}" && git diff'
ismac && __git_complete d _git_diff
alias dc='echo "${red}Diff cached...${reset}" && git diff --cached'
ismac && __git_complete dc _git_diff

# GIT PUSH
alias pf='echo "${red}Force pushing with lease...${reset}" && git push --force-with-lease'
ismac && __git_complete pf _git_push
alias p='echo "${green}Pushing...${reset}" && git push'
ismac && __git_complete p _git_push
alias pup='echo "${green}Pushing...${reset}" && git push 2>&1 >/dev/null | grep -o "[^$(git push) ].*" && echo "pushing special to"'

# GIT PULL
alias pl='echo "${green}Pulling (fast-forward)...${reset}" && git pull --ff-only'
ismac && __git_complete pl _git_pull

# GIT CHECKOUT
alias ck='echo "${green}Checking out branch $1...${reset}" && git checkout $1'
ismac && __git_complete ck _git_checkout
alias ckb='echo "${green}Creating and checking out branch $1...${reset}" && git checkout -b $1'
ismac && __git_complete ckb _git_checkout
alias gcb='git cb'

# GIT OTHER
alias treegit='echo "${green}Git Tree...${reset}" && git log --graph --all --oneline --decorate'
alias sub='echo "${green}Updating submodule...${reset}" && git submodule update'
alias rr='echo "${green}Continuing rebase...${reset}" && git rebase --continue'
alias gign='git update-index --assume-unchanged'
# __git_complete gign _git_update_index
alias gignr='git update-index --no-assume-unchanged'
# __git_complete gignr _git_update_index

alias gf='echo "${green}Fetching...${reset}" && git fetch -tpa'
# __git_complete gf _git_fetch

alias gr='echo "${green}Resetting${reset}" && git reset'
ismac && __git_complete ckb _git_reset
alias gr1='gr HEAD^'
ismac && __git_complete ckb _git_reset
alias gr2='gr HEAD^^'
ismac && __git_complete ckb _git_reset
alias gr3='gr HEAD^^^'
ismac && __git_complete ckb _git_reset

alias grh='echo "${red}Resetting with --hard${reset}" && git reset --hard'
ismac && __git_complete ckb _git_reset
alias grh1='grh HEAD^'
ismac && __git_complete ckb _git_reset
alias grh2='grh HEAD^^'
ismac && __git_complete ckb _git_reset
alias grh3='grh HEAD^^^'
ismac && __git_complete ckb _git_reset

# Dangling commits
alias dangit="git fsck --lost-found | grep 'dangling commit' | cut -d' ' -f 3 | xargs -I '{}' git --no-pager show --stat '{}'"
alias diffmoved="git -c color.diff.newMoved=white -c color.diff.oldMoved=white diff --color-moved=plain"
alias cleanb='echo "Cleaning ${yellow}gone${reset} branches (dry run)" && git branch --merged | grep -v "\*" | grep -v "master" | grep -v "develop" | grep -v "staging" | xargs -n 1 echo'
alias cleand='echo "Cleaning ${yellow}gone${reset} branches" && git branch --merged | grep -v "\*" | grep -v "master" | grep -v "develop" | grep -v "staging" | xargs -n 1 git branch -d'
alias syng='git stash && gf && cleanb'

alias lg="lazygit"

git-clean() {
  branchesfile=$(mktemp)
  trap "{ rm -f $branchesfile; }" EXIT

  # Remove references to remote branches that no longer exist.
  git remote prune origin
  # Create a file containing list of all merged branches.
  git branch | grep -v master >$branchesfile

  $(git var GIT_EDITOR) $branchesfile
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # Trim trailing and leading whitespace etc.
  sed 's/^[ \t]*//;s/[ \t]*$//' <$branchesfile
  # Soft delete all branches left in the file and then remove tmp file.
  xargs git branch -d <$branchesfile
}

fixup() {
  DOMAINS=(
    "domain.com"
    "example.com"
  )

  PS3="Your choice: "
  select DOMAIN in "${DOMAINS[@]}"; do
    if [[ $DOMAIN ]]; then
      echo "You entered '$REPLY' and selected '$DOMAIN'."
      break
    else
      echo "Error: Invalid choice '$REPLY'"
    fi
  done
}
