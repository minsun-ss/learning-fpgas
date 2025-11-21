# Getting Started with FPGAs

Part of W1'25 Recurse projects!

Although this repo is to work through the [Getting Started with FPGAs](https://nostarch.com/gettingstartedwithfpgas) book, it is also to provide some details on the (moderately more complicated) workflow required to work through the project on open source tooling. 

There are also notes in here for those working through the book offering alternatives to things introduced in the book that are specific to Lattice tooling.

As I am a beginner to all this, please forgive any errors made in this writeup. A more detailed blog post is also here:
<TBD>

# Requirements

A note about the bewildering variety of tools listed; many of them overlap, e.g., if you end up installing yosys via the oss-cad-suite you'll already come with every tool listed as the rest are all already included in the /bin folder. And in fact, that is my recommended way of installing this: just grab the tar from yosys, unpack, and activate the env with their shell script. 

The tools suggested for the workflow below:

For synthesizing, placing, routing and programming:

- project icestorm tools: https://prjicestorm.readthedocs.io/en/latest/overview.html
- yosys (synthsiser): https://github.com/YosysHQ/yosys - if you want to make sure you have access to all these tools you can either install to /usr or just source the folder (suggested to put it in /opt).
- nextpnr (place and route): https://github.com/YosysHQ/nextpnr

For simulation and testbench: 

- iverilog (icarus verilog) https://steveicarus.github.io/iverilog/usage/installation.html
- gtkwave (wave viewer) : https://gtkwave.sourceforge.net/

A note about Project Icestorm recommendations: it suggests installing arachne and nextpnr, but in 2025 you really only need nextpnr (arachne is deprecated). 

If you want to build and install the tools separately, or just want the latest version, here are my notes for them when I did it; rather fortunately (unfortunately?) I did the building before realizing they were all already in the oss-cad-suite.

Notes for Nextpnr: 
- NextPNR requires the DARCH flag to be set for building for iCE40 boards. `cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local .` For Debian, this didn't work out of the box for me; I had to add the specification of a separate build folder to make work, which all following commands afterward must be in to run (e.g., make build and make install)

```
# cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local . -B build
# cd build && sudo make build
```

Due to its reliance on locating python for its build, if you have a specialized set up for your python environments and don't rely on system python at all (e.g., pyenv, uv), you'll need to specify your specific location in the variable PYTHON_ENVIRONMENT. I keep a pyenv for this and you'll have to call `pyenv which python` to get the location of your python binaries instead. 

# To Run

yosys should be installed as part of the [OSS suite](https://github.com/YosysHQ/oss-cad-suite-build/?tab=readme-ov-file). The tar should be unpacked in /opt/oss-cad-suite. To activate the oss-cad-suite:

```
source oss-cad-suite/environment
```

Simluating and running test benches:
```
make sim PROJ=ProjectName
```

This will simulate all *.v and *.sv files in src/ProjectName folder. If you have a _Top module specified, the filename should also contain _Top and it will default to that as the top module; if it's not included it will use the project name as the topmost module.

Building an existing FPGA workflow. This will also move it to fpga as well using iceprog.

```
make build
```

# Troubleshooting

If you need to identify the USB port, it's USB1, *not* USB0, for the nandland go board. This also mentioned in the book (see page 28). iceprog does not care, it will automatically find it for you, but if you have trouble with the device being recognized, then this is what you should set.

# Current Chapter Work: 5s
