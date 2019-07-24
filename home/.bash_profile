################################################################################
#                                                                              #
#          Use the .bash_profile.gpg instead of appending this file.           #
#                                                                              #
################################################################################

set -x
# Start our gpg-agent and populate gpg-agent-info if it does not exist
/bin/ps -ef | /usr/bin/grep -v /usr/bin/grep | /usr/bin/grep -q gpg-agent
export EXIT=$?
if [ ${EXIT} -ne 0 ]; then
    set -x
    if [[ $(uname) == Darwin ]]; then
        export GPG_TTY=$(tty)
        if [[ -n "$SSH_CONNECTION" ]] ;then
            export PINENTRY_USER_DATA="USE_CURSES=1"
        fi
        /usr/local/bin/gpg-agent --daemon  2>&1
        export GPG_TTY=$(tty)
    fi
    set +x
fi

ping -c1 $(dig +short github.com|head -1) > /dev/null 2>&1
if [ $? -eq 0 ]; then
  (cd ${HOME}/.dotfiles; git pull origin master > /dev/null 2>&1)
fi

# Source our encrypted .bash_profile
# . <(gpg --no-tty -qd ${HOME}/.bash_profile.gpg)

# Known limitation in bash 3.2 http://stackoverflow.com/questions/32596123/why-source-command-doesnt-work-with-process-substitution-in-bash-3-2
source /dev/stdin <<<"$(cat <(gpg --no-tty -qd ${HOME}/.bash_profile.gpg 2>/dev/null))"
