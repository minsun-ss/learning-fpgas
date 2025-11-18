# Getting Started with FPGAs

Part of W1'25 Recurse projects!

Although this repo is to work through the [Getting Started with FPGAs](https://nostarch.com/gettingstartedwithfpgas) book, it is also to provide some details on the (moderately more complicated) workflow required to work through the project on open source tooling. 

There are also notes in here for those working through the book offering alternatives to things introduced in the book that are specific to Lattice tooling.

As I am a beginner to all this, please forgive any errors made in this writeup. A more detailed blog post is also here:
<TBD>

# Requirements

A note about the bewildering variety of tools listed; many of them overlap, e.g., if you end up installing yosys via the oss-cad-suite you'll already come with every tool listed as the rest are all already included in the /bin folder. And in fact, that is my recommended way of installing this: just grab the tar from yosys, unpack, and activate the env with their shell script. 

The tools suggested for the workflow below:

- iverilog (icarus verilog) https://steveicarus.github.io/iverilog/usage/installation.html
- project icestorm tools: https://prjicestorm.readthedocs.io/en/latest/overview.html
- gtkwave (wave viewer) : https://gtkwave.sourceforge.net/
- yosys (synthsiser): https://github.com/YosysHQ/yosys - if you want to make sure you have access to all these tools you can either install to /usr or just source the folder (suggested to put it in /opt).
- nextpnr (place and route): https://github.com/YosysHQ/nextpnr

A note about Project Icestorm recommendations: it suggests installing arachne and nextpnr, but in 2025 you really only need nextpnr (arachne is deprecated). 

Notes for Nextpnr: 
- NextPNR requires the DARCH flag to be set for building. `cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local .` For Debian, this didn't work out of the box for me; I had to add the specificationn of a separate build folder to make work, which all following commands afterward must be in to run (e.g., make build and make install)

```
# cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local . -B build
# cd build && sudo make build
```

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

# Some alternate equivalents as you go through the chapters

## Chapter 3:

There is a discussion in chapter 3 about a report tool. A similar report can be retrieved from the yosys stat command; in the make build command there is an output that generates a .stat file for you to read. There is also a .rpt file generated that also details some hot path information as well, but not immediately directly related to the report
