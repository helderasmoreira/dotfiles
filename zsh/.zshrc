# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="intheloop"
plugins=(git autojump dotenv)

source $ZSH/oh-my-zsh.sh

# https://github.com/cantino/mcfly
eval "$(mcfly init zsh)"

# chruby
source /usr/local/share/chruby/chruby.sh

### BEGIN carwow dev

PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
PATH="$(brew --prefix)/opt/findutils/libexec/gnubin:$PATH"
PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"

# Note the folder structure here and adjust accordingly!
PATH=$PATH:$HOME/Work/carwow/dev-environment/bin

### END carwow dev
