# FPGAs!

Part of W1'25 Recurse projects!

Partly to work through the Getting Started with FPGAs book, but also to set up shop with a nandland go.

# Setup

A couple of things are installed here:
- IVerilog: https://github.com/steveicarus/iverilog

There is a install_tooling.sh file to set up all of this for you should you bork your machine.

# Requirements

Some of these recommendations are echoed by [Project Icestorm](https://prjicestorm.readthedocs.io/en/latest/overview.html#where-are-the-tools-how-to-install). Some additional tools are for ease of development.

- iverilog ( icarus verilog ) https://steveicarus.github.io/iverilog/usage/installation.html
- i40 open source flow, project IceStorm : https://prjicestorm.readthedocs.io/en/latest/overview.html
- gtkwave, recomended wave viewer : https://gtkwave.sourceforge.net/
- yosys, synthsiser: https://github.com/YosysHQ/yosys - if you want to make sure you have access to all these tools you can either install to /usr or just source the folder (suggested to put it in /opt).
- nextpnr, place and route: https://github.com/YosysHQ/nextpnr - note, the project icestorm page suggests installing both arachne and nextpnr, but you only need nextpnr as arachne is now deprecated. The major difference between the two is that nextpnr does not accept blif files (only json) and the build here accounts for that; you will need to adjust this if you still insist on using arachne. 

Additional notes for Debian 13 (Trixie) users:
- NextPNR requires the DARCH flag to be set for building. `cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local .` For Debian, this didn't work out of the box for me; I had to add the specificationn of a separate build folder to make work:

```
# cmake -CMAKE_BINARY_DIR  build -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local . -B build
# cmake --build build
```

Aside from the nextpnr issue, the rest of the suites installed fine.

# To Run

yosys should be installed as part of the [OSS suite](https://github.com/YosysHQ/oss-cad-suite-build/?tab=readme-ov-file). The tar should be unpacked in /opt/oss-cad-suite. To activate the oss-cad-suite:

```
fpgashell
```

Building an existing FPGA workflow. This will also move it to fpga as well using iceprog.

```
make build
```

# Troubleshooting

If you need to identify the USB port, it's USB1, *not* USB0, for the nandland go board. This also mentioned in the book (see page 28). iceprog does not care, it will automatically find it for you, but if you have trouble with the device being recognized, then this is what you should set.

# To Do
- Replacing the Lattice workflow for the Nandland Go board
- Write an article on that
- Work through the book
- Write a better makefile for fast workflow


