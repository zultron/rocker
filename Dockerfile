ARG VENDOR=debian
ARG SUITE=stretch

FROM ${VENDOR}:${SUITE}
MAINTAINER John Morris <john@zultron.com>
#
# These variables configure the build.
#
ARG VENDOR=debian
ARG SUITE=stretch
#
# Configure & update apt
ARG DEBIAN_MIRROR
ARG DEBIAN_SECURITY_MIRROR
#ENV DEBIAN_FRONTEND noninteractive
RUN test -z "${DEBIAN_MIRROR}" || bash -c "( \
        echo deb http://${DEBIAN_MIRROR}/debian ${DEBIAN_SUITE} main; \
        echo deb http://${DEBIAN_MIRROR}/debian ${DEBIAN_SUITE}-updates main; \
        echo deb http://${DEBIAN_SECURITY_MIRROR}/debian-security \
            ${DEBIAN_SUITE}/updates main; \
        ) | tee /etc/apt/sources.list"
RUN echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > \
        /etc/apt/apt.conf.d/01norecommend
RUN apt-get update
RUN apt-get upgrade -y && \
    apt-get clean
# silence debconf warnings
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y \
    libfile-fcntllock-perl \
    apt-utils \
    && apt-get clean

# Install and configure sudo, passwordless for everyone
RUN apt-get install -y \
    sudo && \
    apt-get clean
RUN echo "ALL	ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# Cookie variable for container environment
ENV ENV_COOKIE docker

###########################################
# Install packages
#
# Customize the following for building/running targeted software

# Utilities needed later
RUN apt-get install -y \
    gnupg2 \
    dirmngr \
    curl \
    wget \
    && apt-get clean


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
	ccache && \
    apt-get clean

# Qt5
RUN apt-get install -y \
	qt5-qmake \
	qtcreator \
	qt5-default \
	qt-sdk \
	libqt5opengl5-dev \
	qtdeclarative5-dev \
	qtdeclarative5-dev-tools \
	qttools5-dev-tools \
	qml-module-qtquick-extras \
	qml-module-qtquick-dialogs \
	qml-module-qt-labs-folderlistmodel \
	qml-module-qt-labs-settings \
	qml-module-qtquick-xmllistmodel \
	qml-module-qtquick-particles2 \
	qmlscene \
	qbs \
	qbs-dev \
	libqt5svg5-dev \
    && apt-get clean

# Qt4
RUN apt-get install -y \
	libqt4-dev \
	libqt4-opengl-dev \
	qt4-dev-tools \
	libsoqt4-dev \
	qt4-qmlviewer \
	python-qt4 && \
    apt-get clean

# Boost
RUN apt-get install -y \
	libboost-dev \
	libboost-filesystem-dev \
	libboost-regex-dev \
	libboost-program-options-dev \
	libboost-signals-dev \
	libboost-thread-dev \
	libboost-python-dev && \
    apt-get clean

# Python
RUN apt-get install -y \
	python-dev \
	python-pyside \
	pyside-tools && \
    apt-get clean

# OCE
RUN apt-get install -y \
	liboce-foundation-dev \
	liboce-modeling-dev \
	liboce-ocaf-dev \
	liboce-visualization-dev \
	liboce-ocaf-lite-dev \
	oce-draw && \
    apt-get clean

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
	libspnav-dev && \
    apt-get clean

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
	gnome-icon-theme \
	intltool \
    && apt-get clean

# PathPilot
RUN apt-get install -y \
	redis-server && \
    apt-get clean

# MK deps; not on Ubuntu
#
RUN test ${VENDOR} = ubuntu || { \
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
        libcgroup-dev \
    && \
    apt-get clean; \
    }
#	libxenomai-dev

# Scan Tailor
RUN apt-get install -y \
	libboost-all-dev \
	tesseract-ocr \
	tesseract-ocr-eng \
	tesseract-ocr-deu && \
    apt-get clean

# libpgm
RUN apt-get install -y \
        dh-autoreconf && \
    apt-get clean

# Python debugging
RUN apt-get install -y \
	python-pip \
    && apt-get clean
RUN test ${VENDOR} = ubuntu || \
    pip install -U \
	pip \
	setuptools \
	pylint

# Coreboot
RUN apt-get install -y \
	gnat flex bison wget \
    && apt-get clean

# Extra packages
ARG EXTRA_PACKAGES
RUN test -z "${EXTRA_PACKAGES}" || { \
        apt-get install -y ${EXTRA_PACKAGES} \
        && apt-get clean; \
    }


###########################################
# Set up user
#

# This shell script adds passwd and group entries for the user
COPY entrypoint.sh /usr/bin/entrypoint
ENTRYPOINT ["/usr/bin/entrypoint"]
# If no args to `docker run`, start an interactive shell
CMD ["/bin/bash", "--login", "-i"]
