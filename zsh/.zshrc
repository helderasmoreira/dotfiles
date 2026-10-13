# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="intheloop"
plugins=(autojump dotenv)

fpath=($HOME/.docker/completions $fpath)

source $ZSH/oh-my-zsh.sh

# https://github.com/cantino/mcfly
eval "$(mcfly init zsh)"

# rbenv
eval "$(rbenv init - zsh)"

export PATH="$HOME/.local/bin:$PATH"

### BEGIN carwow dev

PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
PATH="$(brew --prefix)/opt/findutils/libexec/gnubin:$PATH"
PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"

# Note the folder structure here and adjust accordingly!
PATH=$PATH:$HOME/Work/Carwow/dev-environment/bin

### END carwow dev

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
