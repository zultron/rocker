# `rocker`:  Containers for your desktop without the boilerplate

The `rocker` script takes the boilerplate out of building (optionally)
and running containers, passing your user ID, home directory and
display in from the host environment so you can work in the container
much as you would on the host.  Common use cases for Docker are
trivial with `rocker`:

- **Run a graphical application on your desktop** from a container:  full
  access to your home directory, display and audio
- **Run/develop/test an application in a different OS release** than
  the host
- **Run an arbitrary container image** with your user ID and home
  directory

The simplest common use cases need just a single command line to run
an existing container image, or functionality may be easily augmented
by adding a simple `.rocker` configuration file and/or building onto a
base image.

There's no magic here, but `rocker` centralizes tedious boilerplate
for building and running images in one script, with four major
functions to generate the `Dockerfile`, the `docker build` and
`docker run` commands, and the `ENTRYPOINT` script:

- **Build your changes into a container image:**
  - **Template a `Dockerfile`** with common boilerplate
    - Start from any arbitrary base Docker image
    - **Add canned changes out of the box**, all configurable:
      - Install **passwordless `sudo`** in image
      - Optionally **upgrade OS packages**
    - **Add your own `Dockerfile` snippet**:
      - Append a line or two from a `.rocker` config variable
      - Append more complex snippets from a `.rockerfile`
  - **Execute `docker build`** with configurable arguments
- **Run a container with access to host resources:**
  - **Execute `docker run`** with scripted arguments
    - Pass in your user/group ID
    - Bind-mount your home directory
    - Bind-mount graphics and audio devices
    - Set the same `$CWD` as outside the container
  - **Serve as `ENTRYPOINT` script** inside the container to configure
    the environment
    - If the container image wasn't built by `rocker`, set up `sudo`
    - Configure your user and groups
    - Configure environment variables:  `$HOME`, `$USER`
    - `exec` the container command (`bash` login shell by default)
      with your UID

## Installation

For quick and easy installation and use, `rocker` is a single `bash`
script you can copy (or symlink) to `~/bin/rocker`:

    curl -Lso ~/bin/rocker https://github.com/zultron/rocker/raw/master/rocker
    chmod +x ~/bin/rocker

## `.rocker` configuration file (optional)

The `.rocker` file configures `rocker` both to build and run a
container.  While optional, it simplifies nuanced configuration for
all but the most simple use cases.

The `.rocker` file is simply a `bash` configuration script that
`rocker` looks for and sources in the current working directory.
Configuration is nominally in the form of `bash` variables beginning
with `ROCKER_`, but any bash script may be included.  The variables
are described in the below sections for building images and running
containers.

## Building images

    rocker -b [-p] [-i ROCKER_BASE_IMAGE] [-t ROCKER_IMAGE_TAG] [ARGS...]

The `-b` argument puts `rocker` in `docker build` mode.  The `-p`
argument prints the templated `Dockerfile` and `docker build` command,
but doesn't do anything.  Any final `ARGS...` will be appended to the
`docker build` command.

These environment variables or `.rocker` variables configure the
`docker run` command:
- `ROCKER_BASE_IMAGE`:  Base Docker image to build `FROM`; also `-i`
- `ROCKER_IMAGE_TAG`:  Tag the built image with this name; also `-t`;
  default `${ROCKER_BASE_IMAGE}_overlay`
- `ROCKER_UPGRADE_BASE_OS`: Run `apt-get upgrade` (default `true`)
- `ROCKER_EXTRA_PACKAGES`:  List of APT packages to install (`bash`
  array variable, `.rocker` only)
- `ROCKER_DOCKERFILE_SNIPPET`:  A snippet to add at the end of the
  `Dockerfile`
- `ROCKER_DOCKERFILE`:  Path to an optional file containing a
  `Dockerfile` snippet, appended to the generated `Dockerfile`;
  `.rockerfile` by default
- `ROCKER_LOAD_CONTEXT`:  If `true`, load the current directory into
  the Docker build context (default: `false`)

## Running containers

    rocker [-p] [-n ROCKER_NAME] [-t ROCKER_IMAGE_TAG] [COMMAND [ARGS...]]

`rocker` will will start a container.  With itself as the entrypoint
inside the container, it will configure your user and groups the same
as on the host, configure `$USER` and `$HOME` environment variables,
and `exec` the `COMMAND` with optional `ARGS...` (`bash` login shell
by default).

With the `-p` argument, `rocker` will print the `docker run` command
it would have executed, but will not actually start a container.

Even if the image was not built with `rocker -b`, `rocker -t
arbitrary:image` will start a container as usual, additionally
installing passwordless `sudo`.  This enables powerful one-line use
cases, e.g. to run a shell in any arbitrary pulled an image, install
packages as `root`, and run programs with your user ID.

These environment variables or `.rocker` variables configure the
`docker run` command:
- `ROCKER_IMAGE_TAG`:  Docker image tag to run; also `-t`
- `ROCKER_NAME`:  Container name and hostname; also `-n` (default:
  `rocker`)
- `ROCKER_RUN_DETACHED`:  Run container detached if `true` (default:
  `false`)
- `ROCKER_PRIVILEGED`:  Run container with `--privileged` arg
- `ROCKER_INIT`:  If set, the `entrypoint` script will exec this as
  pid 1 (default:  use `docker run --init`)
- `ROCKER_GROUPS`:  List of extra groups to add user to
- `ROCKER_RUN_ARGS`:  List of extra `docker run` args to add to
  command line (May be used as array variable in `.rocker`)

## Running containers:  `rocker`ized apps

An application may be `rocker`ized so that you can run e.g. `myapp
--arg1 --arg2=foo` directly from the command line, as though you were
running an application installed directly on the host.

The `ROCKER_ENTRYPOINT_COMMAND` option adds the `COMMAND` run as the
user out of the entrypoint script with `ARGS....` (e.g. `myapp --arg1
--arg2=foo`).

A symlink `myapp` pointing to `rocker` (with rocker in `~/bin/rocker`,
`ln -s rocker ~/bin/myapp`) tells `rocker` to look for a `rocker`
image with label `ROCKER_IMAGE_TAG=myapp`.  If it finds that image, it
will examine image labels and extract configs found in the original
`.rocker` file, and start the container.  A symlink `myapp.tag` tells
`rocker` to look for an image labeled `ROCKER_IMAGE_TAG=myapp:tag`.

The usual `rocker` run args are ignored, and any command line args are
passed into the entrypoint command.

## License

Permissive 3-clause BSD license.  Feel free to use `rocker` in your
projects.

## Working examples

### ROS2 Galactic Geochelone

From your ROS2 workspace directory, start a shell:

    rocker -t osrf/ros:galactic-desktop

Now start developing:

    source /opt/ros/$ROS_DISTRO/setup.bash
    colcon build

### More working examples coming soon!

-----

## TODO

- Add `docker run` configuration to built image in a label so that
  `rocker -t my_rocker_image` starts up the right way, even in the
  absence of the `.rocker` config
- Pass list of groups and host GIDs into container; add if missing,
  and resolve GID conflicts:  useful for passing in group-writable
  e.g.  devices (`/dev/EtherCAT0`) & sockets (`/run/docker.sock`)
