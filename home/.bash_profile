################################################################################
#                                                                              #
#          Use the .bash_profile.gpg instead of appending this file.           #
#                                                                              #
################################################################################
export BASH_SILENCE_DEPRECATION_WARNING=1

function parse_git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

function hug_parse_git_branch {
  if [ ! -z "$(parse_git_branch)" ]; then
    echo "("$(parse_git_branch)")"
  else
    echo ""
  fi
}

################################################################################
# Start our gpg-agent and populate gpg-agent-info if it does not exist         #
################################################################################
/bin/ps -ef | /usr/bin/grep -v /usr/bin/grep | /usr/bin/grep -q gpg-agent
export EXIT=$?
if [ ${EXIT} -ne 0 ]; then
    if [[ $(uname) == Darwin ]]; then
        export GPG_TTY=$(tty)
        if [[ -n "$SSH_CONNECTION" ]] ;then
            export PINENTRY_USER_DATA="USE_CURSES=1"
        fi
        [ -x /opt/homebrew/bin/gpg-agent ] && /opt/homebrew/bin/gpg-agent --daemon  2>&1
        [ -x /usr/local/bin/gpg-agent ]    && /usr/local/bin/gpg-agent --daemon  2>&1
        export GPG_TTY=$(tty)
    fi
fi
[ -x /usr/local/bin/gpgconf ] && export GPG_AGENT_INFO=$(/usr/local//bin/gpgconf --list-dirs agent-socket)
[ -x /opt/homebrew/bin/gpgconf ] && export GPG_AGENT_INFO=$(/usr/local//bin/gpgconf --list-dirs agent-socket)

ping -c1 $(dig +short github.com|head -1) > /dev/null 2>&1
if [ $? -eq 0 ]; then
  (cd ${HOME}/.dotfiles; git pull origin master > /dev/null 2>&1)
fi

# Source our encrypted .bash_profile
# . <(gpg --no-tty -qd ${HOME}/.bash_profile.gpg)

# Known limitation in bash 3.2 http://stackoverflow.com/questions/32596123/why-source-command-doesnt-work-with-process-substitution-in-bash-3-2
source /dev/stdin <<<"$(cat <(gpg --no-tty -qd ${HOME}/.bash_profile.gpg 2>/dev/null))"
export PATH="/usr/local/opt/terraform@0.11/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
if [ "$TERM" == "tmux-256color" ]; then export TERM="screen-256color"; fi
COMPUTERNAME=$(scutil --get ComputerName)
[ ! -z ${COMPUTERNAME} ] && sudo hostname ${COMPUTERNAME}
PS1="\h:\W \$(hug_parse_git_branch)\$ "
