#!/bin/bash

#
# Git insulation
#
DEFAULT_SUITE=jessie
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
