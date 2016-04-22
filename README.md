# Docker dev container

This Dockerfile builds images with the basic tools for developing
LinuxCNC/Machinekit and FreeCAD.  The `master` branch builds Debian
Jessie-based images, and `trusty` builds Ubuntu Trusty-based images.

## Building

To build the image, check out the desired branch, then:

	./build.sh

This will build a Docker image, `dev-${SUITE}` (default:
`dev-jessie`).

## Running

To run the image, `cd` to the directory containing the code under
development, and:

	[...]/docker-dev.sh [-s ${SUITE}]

This will run a shell in the container, default `dev-jessie` unless
otherwise specified on the command-line (e.g. `-s trusty`), in the
following way:

- The container will be named after the image, e.g. `dev-jessie`
- The current directory will be bind-mounted in the same location
  within the container, and the shell will start there
- The user and group ID will be set inside same as outside
- So that X clients may run from within the container, the X11 socket
  and DRI directories will be bind-mounted, the `$DISPLAY` variable
  will be set, and the container will run privileged
- When the container exits, it will be destroyed; nothing will persist
  to the next run except the contents of the bind-mounted directory

The script runs an interactive `bash` shell by default.  A command
with args may also be specified, for example:

	$ [...]/docker-dev.sh -s trusty bash -c 'echo $SUITE'
	trusty

