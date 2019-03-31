# Did you mean .bash_profile? :trollface:
[ ! -z "${BASH_LASTCOMMAND}" ] && history -s "${BASH_LASTCOMMAND}"
. ~/.bash_profile
[ ! -z "${BASH_DIRECTORY}" ] && cd ${BASH_DIRECTORY}
[ ! -z "${BASH_LASTCOMMAND}" ] && ${BASH_LASTCOMMAND}
