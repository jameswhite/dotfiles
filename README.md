# Manage my dotfiles.

```
git clone https://github.com/jameswhite/dotfiles $HOME/.dotfiles
bash $HOME/.dotfiles/scripts/pull
```

```
 + .dotfiles
    + README.md       you're reading it!
    + home/
    | + bin/          scripts to be deployed and symlinked to ${HOME}/bin everywhere
    | + doc/          documents I want everywhere
    | .somefile       the actual managed dotfile
    | .someotherfile  the actual managed dotfile
    | .somedir/       a dotfile directory
    + scripts/        scripts for managing dotfiles
```
