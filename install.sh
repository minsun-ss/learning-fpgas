#!/bin/sh

for arg in "$@"; do
   case $arg in
       --force)
       echo "Using force"
       exit 0
       ;;
   esac
done

if grep -q "debian\|ubuntu" /etc/os-release; then
    OS_FAMILY="debian"
elif grep -q "arch" /etc/os-release; then
    OS_FAMILY="arch"
elif grep -qi "fedora\|rhel\|centos" /etc/os-release; then
    OS_FAMILY="redhat"
elif [ "$(uname -s)" == "Darwin" ]; then
    if [ "$(uname -m)" == "arm64" ]; then
        OS_FAMILY="macos-arm64"
        echo "Detected Apple Silicon Mac (M1/M2/M3). Family: ${OS_FAMILY}"
    else
        OS_FAMILY="macos-x86"
        echo "Detected Intel Mac. Family: ${OS_FAMILY}"
    fi
fi

echo "LATTICE TOOL INSTALL: OS FAMILY - ${OS_FAMILY}"

# Installing the appropriate files
# we will use the existing python env to be your linked item so... sorry
PYTHON_DIRECTORY=$(which python)
if echo $(which python) | grep -q "pyenv"; then
    echo "LATTICE TOOL INSTALL: Pyenv found, looking for absolute path..."
    PYTHON_DIRECTORY=$(dirname $(dirname $(pyenv which python)))
else
    PYTHON_DIRECTORY=$(dirname $(dirname $(which python)))
fi

echo "LATTICE TOOL INSTALL: Path used to link python - $PYTHON_DIRECTORY"
PYTHON_EXECUTABLE="$PYTHON_DIRECTORY/bin/python"
PYTHON_RUNPATH="$PYTHON_DIRECTORY/lib"

echo "LATTICE TOOL INSTALL: Making sure dev libraries are installed..."

# if [ $OS_FAMILY = "debian" ]; then
#     sudo apt update && sudo apt install -y autoconf gperf make gcc g++ bison flex \
#     build-essential clang libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz  \
#     xdot pkg-config libftdi-dev libboost-all-dev cmake libeigen3-dev libgtk-3-dev
# elif [ $OS_FAMILY = "arch" ]; then
#     pacman -S autoconf gperf make gcc g++ bison flex build-essential \
#     clang libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz  \
#     xdot pkg-config libftdi-dev libboost-all-dev cmake libeigen3-dev
# elif [ $OS_FAMILY = "redhat" ]; then
#     dnf install autoconf gperf make gcc g++ bison flex build-essential \
#     clang libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz  \
#     xdot pkg-config libftdi-dev libboost-all-dev cmake libeigen3-dev
# fi

# Setting up iverilog - or skipping if already installed
echo "LATTICE TOOL INSTALL: Checking on iverilog..."
command -v iverilog >/dev/null 2>&1
IVERILOG_STATUS=$?

if [ "$IVERILOG_STATUS" -eq 0 ]; then
    echo "LATTICE TOOL INSTALL: iverilog verified to have already been installed, skipping."
else
    echo "LATTICE TOOL INSTALL: Pulling down & building iverilog..."
    cd /tmp && git clone https://github.com/steveicarus/iverilog.git
    cd /tmp/iverilog && sh autoconf.sh
    cd /tmp/iverilog && ./configure
    make
    sudo make install
fi

# setting up icestorm
echo "LATTICE TOOL INSTALL: Checking on Icestorm tools..."
command -v iceprog >/dev/null 2>&1
ICESTORM_TOOLS_STATUS=$?

if [ "$ICESTORM_TOOLS_STATUS" -eq 0 ]; then
    echo "LATTICE TOOL INSTALL: Icestorm tools verified to have been installed, skipping."
else
    cd /tmp && git clone https://github.com/YosysHQ/icestorm.git icestorm
    cd /tmp/icestorm
    make -j$(nproc)
    sudo make install
fi

# setting up gtkwave
echo "LATTICE TOOL INSTALL: Checking on GTKWave..."
command -v gtkwave >/dev/null 2>&1
GTKWAVE_STATUS=$?

if [ "$GTKWAVE_STATUS" -eq 0 ]; then
    echo "LATTICE TOOL INSTALL: gtkwave verified to have been installed, skipping."
else
    echo "LATTICE TOOL INSTALL: setting up gtkwave..."
    wget -P /tmp https://gtkwave.sourceforge.net/gtkwave-gtk3-3.3.125.tar.gz
    cd /tmp && tar -xvf gtkwave-gtk3-3.3.125.tar.gz
    cd /tmp/gtkwave*/
    ./configure --enable-gtk3
    make
    sudo make install
fi

# setting up nextpnr
echo "LATTICE TOOL INSTALL: Checking on nextpnr (skipping arachne)..."
command -v nextpnr-ice40 >/dev/null 2>&1
NEXTPNR_STATUS=$?

if [ "$NEXTPNR_STATUS" -eq 0 ]; then
    echo "LATTICE TOOL INSTALL: nextpnr verified to have been installed, skipping."
else
    echo "LATTICE TOOL INSTALL: setting up nextpnr for ice40 boards..."
    cd /tmp && rm -rf /tmp/nextpnr && git clone --recursive https://github.com/YosysHQ/nextpnr nextpnr
    cd /tmp/nextpnr
    cmake -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_INSTALL_RPATH=$PYTHON_RUNPATH . -B build
    cd /tmp/nextpnr/build && make -j$(nproc)
    sudo make install
fi

# validating to make sure udev rules exist; if this is not installed then you have to use sudo for iceprog
echo "LATTICE TOOL INSTALL: Checking on udev rules..."
if [ -f "/etc/udev/rules.d/53-lattice-ftdi.rules" ]; then
    echo "LATTICE TOOL INSTALL: udev rules for Lattice boards have already been established, skipping."
else
    echo "LATTICE TOOL INSTALL: setting up udev rules for lattice boards"
    cd tools && sudo cp tools/53-lattice-ftdi.rules ~/etc/udev/rules.d/
fi

echo "LATTICE TOOL INSTALL: Completed install of all tooling!"
