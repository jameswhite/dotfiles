#!/bin/bash

DOTFILES=$HOME/dotfiles

for f in `ls -A $DOTFILES/home`; do
  #ln -sf $DOTFILES/home/$f $HOME/ 
  echo $f
done

if [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  rm -f $HOME/.gvimrc
  rm -f $HOME/.vimrc
  rm -rf $HOME/.vim

  cp $DOTFILES/home/.gvimrc $HOME/.gvimrc 
  cp $DOTFILES/home/.vimrc $HOME/.vimrc 
  cp -r $DOTFILES/home/.vim $HOME/.gvimrc 
fi
