#### Manage my dotfiles.

```
git clone https://github.com/jameswhite/dotfiles $HOME/.dotfiles
bash $HOME/.dotfiles/scripts/setup.sh
```

  - initialize the dotfiles: `dotmanage -i`
  - put a file under dotfile management: `dotmanage -a <file>`
  - remove a file under dotfile management: `dotmanage -r <file>`


#### Structure
```
 + .dotfiles
    + README.md       you're reading it!
    |
    + home/
    | + bin/          scripts to be deployed and symlinked to ${HOME}/bin everywhere
    | + doc/          documents I want everywhere
    | .somefile       the actual managed dotfile
    | .someotherfile  the actual managed dotfile
    | .somedir/       a dotfile directory
    |
    + scripts/        scripts for managing dotfiles
```
