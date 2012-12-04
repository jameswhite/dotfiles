export DOTFILES=$HOME/.dotfiles

source $DOTFILES/bash/shellopts
source $DOTFILES/bash/aliases


if [[ `uname` =~ "linux" ]] # All linux systems
then
  export TERM=xterm
fi

if [[ `uname -a` =~ "prime" ]] 
then
  export PATH=$PATH:/var/lib/gems/1.9.1/bin
  screen -x main
fi
