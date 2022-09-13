# dotfiles

This is a collection of my dot files, here's a list of features:

- uses stow to install dotfiles
- uses [gitmux](https://github.com/arl/gitmux) for git status in tmux status bar
- uses gbt for command line prompt- Fonts included: Agave Font and Nerd Font
- lots of useful aliases and functions
- unconventional super-quick access git aliases (is is a bad idea to have your git status one key stroke away?)
- private package implemented as a private submodule repository 

## Requirements

Install the following packages:

- tmux: `sudo apt install tmux` / `brew install tmux`
- stow: `sudo apt install stow` / `brew install stow`
- gitmux: go get -u github.com/arl/gitmux
- xclip: `sudo apt install xclip` (macos alternative is called `pbcopy`)
- fzv: `sudo apt install fzf` / `brew install fzf`
- gbt: `go get github.com/jtyr/gbt/cmd/gbt`
- gvm `bash < <(curl -s -S -L <https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer>)`
- direnv: `brew install direnv`
- rust: `brew install rust``
- git-absorb: `cargo install git-absorb`

## Usage

Clone repo in home directory and use `stow` to install packages:

```bash
cd
git clone git@github.com:giannimassi/dotfiles.git
stow os git term private
```

-------------
Note 1: on linux reload fonts with `fc-cache -v -f` after installation.
Note 2: some packages might return an error if a file/dir with the same name are present in the home directory. Remove them or merge them to the files in the dotfiles repo.


## ZSH update
Install plugin manager

```sh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```