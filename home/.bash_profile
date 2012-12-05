if [[ `uname` =~ "linux" ]] 
then
  keychain --clear id_rsa
  source $HOME/.keychain/$HOSTNAME-sh
fi
