(
  cd "${HOME}/.dotfiles"
  git status | egrep -q "(modified|new)"
  EXIT=$?
  if [ $EXIT -eq 0 ]; then
    echo -n "Changes made to dotfiles. Push? [Y/n] "
    read trash
    echo $trash | grep -i -q 'n'
    EXIT=$?
    if [ $EXIT -ne 0 ]; then
      git commit -a -m "dotfiles changed $(date)" && git push origin master
    fi
  fi
)
echo "bye"
