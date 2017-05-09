ping -c1 $(dig +short github.com|head -1) > /dev/null 2>&1
if [ $? -eq 0 ]; then
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
fi
echo "bye"
