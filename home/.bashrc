export DOTFILES=$HOME/.dotfiles

source ~/.bash/shellopts
source ~/.bash/aliases
source ~/.bash/aliasesdev


if [ -t 0 ]; then
  exec screen -S main -xRR
fi
