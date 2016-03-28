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

RUN sed -i /etc/bash.bashrc -e '/^PS1=/ s/^/#/'
ENV PS1 '\h:\W\$ '

# docker create -h dev --name dev -it -u `id -u`:`id -g` -v $PWD:$PWD -w $PWD dev
# docker start -ai dev
#
# or...
# docker run --rm -h dev --name dev -it -u `id -u`:`id -g` -v $PWD:$PWD -w $PWD dev
