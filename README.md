# `rocker`:  Simplify customized container build and run

The `rocker` script helps with common container use cases:

- Add persistent modifications to an existing Ubuntu or Debian image
  - Install additional packages
  - Install configuration files
  - Install dependencies of a ROS workspace
- Run a container with your user ID and home directory bind-mounted
  - Read and write home directory files from containerized software
  - Avoid user ID mismatch issues between container and host
  - Give container access to display and audio hardware
- Simple interface to complex `docker build`/`docker run` commands
  - Defaults cover many use cases
  - A config file allows extra settings to accommodate other use cases

This script is flexible for use in many situations, even while it has
been tailored for use with ROS workspaces.

## `.rocker` configuration file

The `.rocker` file is a `bash` configuration script in the current
directory that `rocker` sources.  Configuration is in the form of
variables beginning with `ROCKER_`.  A complete list follows.

Container run args:
- `ROCKER_IMAGE_TAG`:  Docker image tag to run
- `ROCKER_NAME`:  Container name and hostname (default: `rocker`)
- `ROCKER_RUN_DETACHED`:  Run container detached if `true` (default:
  `false`)
- `ROCKER_PRIVILEGED`:  Run container with `--privileged` arg
- `ROCKER_INIT`:  If set, the `entrypoint` script will exec this as
  pid 1 (default:  use `docker run --init`)
- `ROCKER_RUN_ARGS`:  (Array variable)  List of extra `docker run`
  args to add to command line

Container image build args:
- `ROCKER_IMAGE_TAG`:  Tag built image with this name
- `ROCKER_BASE_IMAGE`:  Base Docker image to build on top of
- `ROCKER_EXTRA_PACKAGES`:  (Array variable)  List of APT packages to
  install
- `ROCKER_LOAD_CONTEXT`:  If `true`, load the current directory into
  the Docker build context (default: `false`)
- ROS workspace configuration:
  - `ROCKER_INSTALL_ROS`:  If `true`, install basic ROS utilities
    (default `false`)
  - `ROCKER_PYTHON`:  Python executable name (default `python3`)
  - `ROCKER_PIP`:  Python executable name (default `pip3`)
  - `ROCKER_WORKSPACE_DEPS`:  Install ROS package dependencies from
    workspace
  - `ROCKER_SKIP_KEYS`:  Don't install these `rosdep` keys
- `.rockerfile`:  If a `.rockerfile` exists next to the `.rocker`
  file, it will be appended to the generated `Dockerfile`
