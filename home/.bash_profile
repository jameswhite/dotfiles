################################################################################
#                                                                              #
#          Use the .bash_profile.gpg instead of appending this file.           #
#                                                                              #
################################################################################

# Remove our gpg-agent-info if the agent is actually dead
/usr/local/bin/gpg-agent > /dev/null 2>&1
EXIT=$?
if [ ${EXIT} -ne 0 ]; then
    /bin/rm -f ${HOME}/.gnupg/gpg-agent-info
fi

# Start our gpg-agent and populate gpg-agent-info if it does not exist
if [[ $(uname) == Darwin ]]; then
  if [ ! -s "${HOME}/.gnupg/gpg-agent-info" ]; then
    # If we're coming in over ssh, don't prompt with the GUI pinentry
    export GPG_TTY=$(tty)
    if [[ -n "$SSH_CONNECTION" ]] ;then
        export PINENTRY_USER_DATA="USE_CURSES=1"
    fi
    unset GPG_AGENT_INFO
    /usr/local/bin/gpg-agent --daemon > ${HOME}/.gnupg/gpg-agent-info
  fi
  if [ ! -s "${HOME}/.gnupg/gpg-agent-info" ]; then
    echo "GPG_AGENT_INFO=/tmp/gpg-GsKLoe/S.gpg-agent; export GPG_AGENT_INFO;" > "${HOME}/.gnupg/gpg-agent-info"
  fi
  . "${HOME}/.gnupg/gpg-agent-info"
  export GPG_TTY=$(tty)
  export GPG_AGENT_INFO
  # export SSH_AUTH_SOCK
fi

ping -c1 $(dig +short github.com|head -1) > /dev/null 2>&1
if [ $? -eq 0 ]; then
  [ -f "${HOME}/tmp/git.err" ] && /bin/rm "${HOME}/tmp/git.err"
  (cd ${HOME}/.dotfiles; git pull origin master > /dev/null 2>"${HOME}/tmp/git.err" )
fi

# Source our encrypted .bash_profile
# . <(gpg --no-tty -qd ${HOME}/.bash_profile.gpg)

# Known limitation in bash 3.2 http://stackoverflow.com/questions/32596123/why-source-command-doesnt-work-with-process-substitution-in-bash-3-2
source /dev/stdin <<<"$(cat <(gpg --no-tty -qd ${HOME}/.bash_profile.gpg 2>/dev/null))"
alias btc='curl -sk https://api.coinbase.com/v2/prices/BTC-USD/buy | jq -rc ".data.amount"'
