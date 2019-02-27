################################################################################
#                                                                              #
#          Use the .bash_profile.gpg instead of appending this file.           #
#                                                                              #
################################################################################

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
        /usr/local/bin/gpg-agent --daemon  2>${HOME}/.gnupg/gpg-agent-err
        export GPG_TTY=$(tty)
    fi
    set +x
fi

ping -c1 $(dig +short github.com|head -1) > /dev/null 2>&1
if [ $? -eq 0 ]; then
  [ -f "${HOME}/tmp/git.err" ] && /bin/rm "${HOME}/tmp/git.err"
  (cd ${HOME}/.dotfiles; git pull origin master > /dev/null 2>"${HOME}/tmp/git.err" )
fi

[ ! -s "${HOME}/tmp/git.err" ] && rm "${HOME}/tmp/git.err"

# Source our encrypted .bash_profile
# . <(gpg --no-tty -qd ${HOME}/.bash_profile.gpg)

# Known limitation in bash 3.2 http://stackoverflow.com/questions/32596123/why-source-command-doesnt-work-with-process-substitution-in-bash-3-2
source /dev/stdin <<<"$(cat <(gpg --no-tty -qd ${HOME}/.bash_profile.gpg 2>/dev/null))"
alias btc='curl -sk https://api.coinbase.com/v2/prices/BTC-USD/buy | jq -rc ".data.amount"'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/jameswhite/lib/google-cloud-sdk/path.bash.inc' ]; then . '/Users/jameswhite/lib/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/jameswhite/lib/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/jameswhite/lib/google-cloud-sdk/completion.bash.inc'; fi
