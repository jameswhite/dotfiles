source ~/.bash/shellopts
source ~/.bash/aliases
source ~/.bash/aliasesdev

export DOTFILES=$HOME/.dotfiles

function dotupdate() {
pushd .
cd $DOTFILES
git add .
git commit -a -m '`date`'
popd
}
