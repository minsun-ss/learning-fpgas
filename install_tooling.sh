#!/bin/bash

# Installing the appropriate files

# Making sure the libraries are already installed
echo "INSTALL TOOLING: Making sure files are already installed..."

if grep -q "debian\|ubuntu" /etc/os-release; then
    sudo apt install -y autoconf gperf make gcc g++ bison flex build-essential \
    clang libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz  \
    xdot pkg-config libftdi-dev libboost-all-dev cmake libeigen3-dev libgtk-3-dev
elif grep -q "arch" /etc/os-release; then
    pacman -S autoconf gperf make gcc g++ bison flex build-essential \
    clang libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz  \
    xdot pkg-config libftdi-dev libboost-all-dev cmake libeigen3-dev
elif grep -qi "fedora\|rhel\|centos" /etc/os-release; then
    dnf install autoconf gperf make gcc g++ bison flex build-essential \
    clang libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz  \
    xdot pkg-config libftdi-dev libboost-all-dev cmake libeigen3-dev
fi

# Setting up iverilog
# echo "INSTALL TOOLING: Pulling down & building iverilog..."
# cd /tmp && git clone https://github.com/steveicarus/iverilog.git
# cd /tmp/iverilog && sh autoconf.sh
# cd /tmp/iverilog && ./configure
# make
# sudo make install

# setting up icestorm
# echo "INSTALL TOOLING: Pulling down icestorm"
# cd /tmp && git clone https://github.com/YosysHQ/icestorm.git icestorm
# cd /tmp/icestorm
# make -j$(nproc)
# sudo make install

# setting up gtkwave
# echo "INSTALL TOOLING: setting up gtkwave"
# wget -P /tmp https://gtkwave.sourceforge.net/gtkwave-gtk3-3.3.125.tar.gz
# cd /tmp && tar -xvf gtkwave-gtk3-3.3.125.tar.gz
# cd /tmp/gtkwave*/
# ./configure --enable-gtk3
# make
# sudo make install

# setting up nextpnr
# echo "INSTALL TOOLING: setting up nextpnr"
# cd /tmp && git clone --recursive https://github.com/YosysHQ/nextpnr nextpnr
# cd /tmp/nextpnr
# cmake -CMAKE_BINARY_DIR  build -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local . -B build
# cmake --build build
# make -j$(nproc)
# sudo make install
