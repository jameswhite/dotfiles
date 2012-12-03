export DROPBOX=/home/arafatm/Dropbox

source $DROPBOX/home/.bash/shellopts
source $DROPBOX/home/.bash/aliases


if [[ `uname` =~ "linux" ]] # All linux systems
then
  source $DROPBOX/home/.bash/linux
  export TERM=xterm
fi

if [[ `uname -a` =~ "prime" ]] 
then
  export PATH=$PATH:/var/lib/gems/1.9.1/bin
  screen -x main
fi
