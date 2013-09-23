source ~/.bash/shellopts
source ~/.bash/aliases
source ~/.bash/aliasesdev

export DOTFILES=$HOME/.dotfiles

function dotupdate() {
pushd .
cd $DOTFILES
if [ -z "$1" ] # Is parameter #1 zero length?
then
  git diff
  echo "You must pass a commit message"
else
  git add .
  git commit -m "$*"
  git push
fi
popd
}
