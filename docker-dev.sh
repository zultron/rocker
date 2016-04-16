#!/bin/bash

#
# Git insulation
#
SUITE=trusty
#
# Git insulation
#

# Parameters
IMAGE=dev-${SUITE}
NAME=${IMAGE}

docker run --rm \
    -it --privileged \
    -u `id -u`:`id -g` \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev/dri:/dev/dri \
    -v $PWD:$PWD \
    -w $PWD \
    -e DISPLAY \
    -h ${NAME} --name ${NAME} \
    ${IMAGE} "$@"
