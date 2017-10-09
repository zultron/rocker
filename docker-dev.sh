#!/bin/bash

#
# Git insulation
#
DEFAULT_SUITE=stretch
#
# Git insulation
#

# Parameters
if test "$1" = -s; then
    shift; SUITE=$1; shift
else
    SUITE=${SUITE-${DEFAULT_SUITE}}
fi
IMAGE=dev-${SUITE}
NAME=${IMAGE}

if test "$1" = build; then
    shift
    exec docker build -t dev-${SUITE} "$@" .
fi

# Check for existing containers
EXISTING="$(docker ps -aq --filter=name=${NAME})"
if test -n "${EXISTING}"; then
    # Container exists; is it running?
    RUNNING=$(docker inspect ${EXISTING} | awk '/"Running":/ { print $2 }')
    if test "${RUNNING}" = "false,"; then
	# Remove stopped container
	echo docker rm ${EXISTING}
    elif test "${RUNNING}" = "true,"; then
	# Container already running; error
	echo "Error:  container '${NAME}' already running" >&2
	exit 1
    else
	# Something went wrong
	echo "Error:  unable to determine status of " \
	    "existing container '${EXISTING}'" >&2
	exit 1
    fi
fi

docker run --rm \
    -it --privileged \
    -u `id -u`:`id -g` \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev/dri:/dev/dri \
    -v $HOME:$HOME \
    -v $PWD:$PWD \
    -w $PWD \
    -e DISPLAY \
    -h ${NAME} --name ${NAME} \
    ${IMAGE} "$@"
