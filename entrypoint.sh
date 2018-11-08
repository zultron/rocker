#!/bin/bash -e

###########################################
# Start services

# Customize the following for starting custom services as root in the
# container

# Start avahi-daemon for MK service discovery
#/etc/init.d/dbus start
#/etc/init.d/avahi-daemon start

###########################################
# Run command as user

# Add user and group to system
echo "${USER}:x:${UID}:${GID}::${HOME}:/bin/bash" >> /etc/passwd
echo "${USER}:x:${GID}:" >> /etc/group

# Run command as user
default_cmd=(/bin/bash --login -i)
exec sudo -u ${USER} -E "${@:-${default_cmd[@]}}"
