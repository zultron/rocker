#!/bin/bash -e

if test "$ENV_COOKIE" = docker; then
    echo "This script cannot run inside a container" >&2
    exit 1
fi

usage() {
    if test -z "$*"; then
        RC=0
    else
        echo "Error:  $*" >&2
        RC=1
    fi
    cat >&2 <<EOF
Usage: $0 [run | exec | build args]
    run args:  [-v VENDOR] [-s SUITE] [-t IMAGE] [-n NAME] [-l LINK] [CMD [ARG ...]]
   exec args:  -e [-s SUITE] [-n NAME] [CMD [ARG ...]]
  build args:  -b [-s SUITE] [-t IMAGE] [-- docker build args]

EOF
    exit $RC
}

while getopts :b-n:l:ev:s:t:h ARG; do
    case $ARG in
        # Build options
	b) BUILD=true ;;
        -) break ;; # Following args passed to docker command
        # Run options
	n) NAME=$OPTARG ;;
        l) LINK_CONTAINER=$OPTARG ;;
        # Exec options
        e) EXEC=true ;;
        # Global options
        v) VENDOR=$OPTARG ;;
	s) SUITE=$OPTARG ;;
	t) IMAGE=$OPTARG ;;
	h) usage ;;
        :) usage "Option -$OPTARG requires an argument" ;;
	*) usage "Illegal option -$OPTARG" ;;
    esac
done
shift $(($OPTIND-1))
BUILD=${BUILD:-false}
EXEC=${EXEC:-false}
SUITE=${SUITE:-stretch}
if test -z "${VENDOR}"; then
    case $SUITE in
        buster|stretch|jessie) VENDOR=debian ;;
        xenial|trusty) VENDOR=ubuntu ;;
        *) usage "Unable to determine vendor; please supply -v" ;;
    esac
fi
NAME=${NAME:-dev-${SUITE}}
TAG=${TAG:-$SUITE}
IMAGE=${IMAGE:-zultron/dev:$TAG}
LINK_CONTAINER=${LINK_CONTAINER:+--link=${LINK_CONTAINER}}

# Allow user to add own settings; scripts may take advantage of
# e.g. ${SUITE} for distro-specific settings
if test -f ${HOME}/.docker-dev-rc.sh; then
    . ${HOME}/.docker-dev-rc.sh
fi

###########################
# Docker build
if $BUILD; then
    cd $(dirname $0)
    # Use a local mirror if specified
    test -z "${DEBIAN_MIRROR}" || DOCKER_DEV_BUILD_OPTS+=(
            --build-arg DEBIAN_MIRROR=${DEBIAN_MIRROR} )
    test -z "${DEBIAN_SECURITY_MIRROR}" || DOCKER_DEV_BUILD_OPTS+=(
            --build-arg DEBIAN_SECURITY_MIRROR=${DEBIAN_SECURITY_MIRROR} )
    set -x
    exec docker build -t "${IMAGE}" \
	 --build-arg VENDOR=$VENDOR \
	 --build-arg SUITE=$SUITE \
	 "${DOCKER_DEV_BUILD_OPTS[@]}" \
	 -f Dockerfile \
	 "$@" .
fi

###########################
# Docker exec
if $EXEC; then
    if test -z "$*"; then
        set -x
        exec docker exec -itu $USER ${NAME} bash
    else
        set -x
        exec docker exec -itu $USER ${NAME} "$@"
    fi
fi

###########################
# Docker run

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

C_UID=$(id -u)
C_GID=$(id -g)
set -x
exec docker run --rm \
    -it --privileged \
    -e UID=${C_UID} \
    -e GID=${C_GID} \
    -e HOME \
    -e USER \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY \
    -v /dev/dri:/dev/dri \
    -v $HOME:$HOME \
    -v $PWD:$PWD \
    -w $PWD \
    -h ${NAME} --name ${NAME} \
    "${DOCKER_DEV_OPTS[@]}" \
    ${LINK_CONTAINER} \
    ${IMAGE} "$@"
