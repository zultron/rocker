FROM debian:jessie
MAINTAINER John Morris <john@zultron.com>
#
# These variables configure the build.
#
ENV SUITE jessie
ENV ARCH  amd64
#
# [Leave surrounding comments to eliminate merge conflicts]
#
# Configure & update apt
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > \
        /etc/apt/apt.conf.d/01norecommend
RUN apt-get update
RUN apt-get upgrade -y
# silence debconf warnings
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y libfile-fcntllock-perl

###########################################
# Install packages

RUN apt-get install -y \
	git \
	devscripts \
	fakeroot \
	equivs \
	lsb-release \
	less \
	python-debian

# Install and configure sudo, passwordless for everyone
RUN apt-get -y install sudo
RUN echo "ALL	ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

###########################################
# Set up environment

# User entry
ENV USER jman
RUN echo "${USER}:x:1000:1000::/home/${USER}:/bin/bash" >> /etc/passwd
RUN echo "${USER}:x:1000:" >> /etc/group

# bash prompt and 'ls' alias
RUN sed -i /etc/bash.bashrc \
    -e 's/^PS1=.*/PS1="\\h:\\W\\$ "/' \
    -e '$a alias ls="ls -aFs"'

###########################################
# Run the container

# docker create -h dev --name dev -it -u `id -u`:`id -g` -v $PWD:$PWD -w $PWD dev
# docker start -ai dev
#
# or...
# docker run --rm -h dev --name dev -it -u `id -u`:`id -g` -v $PWD:$PWD -w $PWD dev
