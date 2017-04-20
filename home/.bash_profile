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
    unset GPG_AGENT_INFO
    /usr/local/bin/gpg-agent --daemon > ${HOME}/.gnupg/gpg-agent-info
  fi
  . "${HOME}/.gnupg/gpg-agent-info"
  export GPG_AGENT_INFO
  # export SSH_AUTH_SOCK
fi

# If we're coming in over ssh, don't prompt with the GUI pinentry
export GPG_TTY=$(tty)
if [[ -n "$SSH_CONNECTION" ]] ;then
    export PINENTRY_USER_DATA="USE_CURSES=1"
fi

# Source our encrypted .bash_profile
. <(gpg --no-tty -qd ~/.bash_profile.gpg)
