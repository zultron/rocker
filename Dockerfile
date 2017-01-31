FROM debian:jessie
MAINTAINER John Morris <john@zultron.com>
#
# These variables configure the build.
#
ENV SUITE jessie
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

# Install and configure sudo, passwordless for everyone
RUN apt-get -y install sudo
RUN echo "ALL	ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

###########################################
# Install packages
#
# Customize the following for building/running targeted software

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
	libtool \
	ccache

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
	netcat-openbsd \
	libpth20 \
	python-gtksourceview2 \
	python-gtkglext1 \
	python-vte \
	python-gst0.10 \
	gnome-icon-theme \
	gstreamer0.10-plugins-base

# PathPilot
RUN apt-get install -y \
	redis-server

# MK deps; not on Ubuntu
RUN test ${SUITE} = trusty || { \
    echo "deb http://deb.machinekit.io/debian ${SUITE} main" > \
	/etc/apt/sources.list.d/machinekit.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 43DDF224 && \
    apt-get update && \
    apt-get install -y \
	automake \
	cython \
	uuid-dev \
	uuid-runtime \
	libzmq3-dev \
	libczmq-dev \
	libprotobuf-dev \
	protobuf-compiler \
	python-protobuf \
	libjansson-dev \
	liburiparser-dev \
	libwebsockets-dev \
	libssl-dev \
	libavahi-client-dev \
	python-pyftpdlib \
	python-zmq \
	python-setuptools \
	libprotoc-dev \
	python-simplejson \
	libxenomai-dev; \
    }

# Scan Tailor
RUN apt-get install -y \
	libboost-all-dev \
	tesseract-ocr \
	tesseract-ocr-eng \
	tesseract-ocr-deu

# libpgm
RUN apt-get install -y \
        dh-autoreconf

# Python debugging
RUN apt-get install -y \
	python-pip
RUN pip install -U \
	pip \
	setuptools \
	pylint

###########################################
# Set up environment
#
# Customize the following to match the user's environment

# Set up user ID inside container to match your ID
ENV USER jman
ENV UID 1000
ENV GID 1000
ENV HOME /home/${USER}
ENV SHELL /bin/bash
ENV PATH /usr/lib/ccache:$PATH
RUN echo "${USER}:x:${UID}:${GID}::${HOME}:${SHELL}" >> /etc/passwd
RUN echo "${USER}:x:${GID}:" >> /etc/group

# Customize the run environment to your taste
# - bash prompt
# - 'ls' alias
RUN sed -i /etc/bash.bashrc \
    -e 's/^PS1=.*/PS1="\\h:\\W\\$ "/' \
    -e '$a alias ls="ls -aFs"'
