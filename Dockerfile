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

# Basic dev tools
RUN apt-get install -y \
	git \
	build-essential \
	devscripts \
	fakeroot \
	equivs \
	lsb-release \
	less \
	python-debian \
	libtool

# Qt5
RUN apt-get install -y \
	qt5-qmake \
	qtcreator \
	qt5-default \
	qt-sdk \
	libqt5opengl5-dev

# Qt4
RUN apt-get install -y \
	libqt4-dev \
	libqt4-opengl-dev \
	qt4-dev-tools \
	libsoqt4-dev \
	python-qt4

# Boost
RUN apt-get install -y \
	libboost-dev \
	libboost-filesystem-dev \
	libboost-regex-dev \
	libboost-program-options-dev \
	libboost-signals-dev \
	libboost-thread-dev \
	libboost-python-dev

# Python
RUN apt-get install -y \
	python-dev \
	python-pyside \
	pyside-tools

# OCE
RUN apt-get install -y \
	liboce-foundation-dev \
	liboce-modeling-dev \
	liboce-ocaf-dev \
	liboce-visualization-dev \
	liboce-ocaf-lite-dev \
	oce-draw

# FreeCAD deps
RUN apt-get install -y \
	python-matplotlib \
	libcoin80-dev \
	libxerces-c-dev \
	libeigen3-dev \
	libqtwebkit-dev \
	libshiboken-dev \
	libpyside-dev \
	libode-dev \
	swig \
	libzipios++-dev \
	libfreetype6 \
	libsimage-dev \
	checkinstall \
	python-pivy \
	doxygen \
	graphviz \
	libcoin80-doc \
	libspnav-dev

# LCNC deps
RUN apt-get install -y \
	autoconf \
	libudev-dev \
	libmodbus-dev \
	libusb-1.0-0-dev \
	libncurses5-dev \
	libxaw7-dev \
	libglib2.0-dev \
	libgtk2.0-dev \
	kmod \
	psmisc \
	bwidget \
	libtk-img \
	tclx \
	libreadline-gplv2-dev \
	tcl8.6-dev \
	tk8.6-dev \
	python-gtk2 \
	python-glade2 \
	python-tk \
	netcat-openbsd

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
