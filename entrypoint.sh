#!/usr/bin/env bash
#===============================================================================
#          FILE: init.sh
#
#         USAGE: ./init.sh
#
#   DESCRIPTION: Entrypoint for docker container
#
#      REVISION: 1.0
#===============================================================================

set -o nounset                              # Treat unset variables as an error

source $HOME/.bashrc

### usage: Help
# Arguments:
#   none)
# Return: Help text
usage() {
	local RC=${1:-0}
    echo "Usage: ${0##*/} [-opt] [command]
Options (fields in '[]' are optional, '<>' are required):
    -h          This help

The 'command' (if provided and valid) will be run instead of default commands
" >&2
    exit $RC
}

while getopts ":h" opt; do
    case "$opt" in
        h) usage ;;
        "?") echo "Unknown option: -$OPTARG"; usage 1 ;;
        ":") echo "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))


if [[ $# -ge 1 && -x $(which $1 2>&-) ]]; then
    exec "$@"
elif [[ $# -ge 1 && $1 != '-' ]]; then
    echo "ERROR: command not found: $1"
    exit 13
else
	if [[ $# -ge 1 && "X$1" == 'X-' ]]; then
		shift
	fi
	
	echo Starting TOS
	
	groupadd -g ${GID} talend && \
	useradd -u ${UID} -g talend -d /home/talend -s /bin/bash talend  && \
	( [ -e /home/talend/.profile ] || cp -drp /etc/skel/. /home/talend/. ) && \
	chown -R talend:talend /home/talend && \
    true

	# pass XAUTH to Docker if XAUTH is set
	[ "X$XAUTH" != "X" ] && su talend -c "xauth add unix:0 $XAUTH"
	exec su talend -c "cd ; PATH=$JAVA_HOME/bin:$PATH exec /apps/TOS_DI/TOS_DI-linux.sh"
	#exec su talend -c "cd ; PATH=$JAVA_HOME/bin:$PATH exec /apps/TOS_DI/TOS_DI-linux-gtk-x86"
	
fi
