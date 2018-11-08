# Docker dev container

A Dockerfile for images with basic software build tools.

Out of the box, packages are installed to build and run
LinuxCNC/Machinekit, FreeCAD and some others.  The Dockerfile is
easily modified to support other software.

## Building

To build the image for Debian Squeeze (default), run

	./docker-dev.sh -b

or for Ubuntu Xenial, run

    ./docker-dev.sh -b -s xenial

## Running

To run the image, `cd` to the source code tree, and to build for
Debian Squeeze (default), run

	[...]/docker-dev.sh

or for Ubuntu Xenial, run

    [...]/docker-dev.sh -s xenial

This will run a shell in the container in the following way:

- The container will be named after the Debian or Ubuntu suite,
  e.g. `dev-stretch`
  - The container name may be overridden with the `-n NAME` argument
- The home directory `$HOME` will be bind-mounted in the same location
  within the container
- The current directory will be bind-mounted in the same location
  within the container, and the shell will start there
- So that X clients may run from within the container, the X11 socket
  and DRI directories will be bind-mounted, the `$DISPLAY` variable
  will be set, and the container will run privileged
- The entrypoint script will run as root
  - It may optionally be customized to start system services within
    the container
  - It adds a new user and group within the container to match those
    outside so that things work sensibly, e.g. file ownership
- When the container exits, it will be destroyed; nothing will persist
  to the next run except the contents of the bind-mounted directory

The script runs an interactive `bash` shell by default.  A command
with args may also be specified, for example:

	$ [...]/docker-dev.sh -s xenial bash -c 'echo $SUITE'
	xenial

To start an additional shell in the running Stretch (default)
container, run

    [...]/docker-dev.sh -e

or to run a command in the running Xenial container, run

    [...]/docker-dev.sh -en xenial cmd arg1 arg2
