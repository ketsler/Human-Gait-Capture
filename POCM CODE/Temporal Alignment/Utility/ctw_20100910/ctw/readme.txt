Introduction
    This page contains software and instructions for Canoical Time Warping (CTW) [1]. All the functions have been written and documented in Matlab format. We additionally provide C++ implementations of some dynamic programming routines which involve many loops and are notoriously slow in Matlab.
        [1] F. Zhou and F. de la Torre, "Canonical time warping for alignment of human behavior", Neural Information Processing Systems (NIPS), 2009.



Installation
    1. unzip aca.zip to your folder;
    2. Run make.m to compile all C++ files;
    3. Run addPath.m to add sub-directories into the path of Matlab.
    4. Run demoCtw file.



Instructions
    The package of aca.zip contains two folders, two setup files and one demo file:
    ./src: This folder contains the main implmentation of CTW.
    ./lib: This folder contains some necessary library functions.
    ./make.m: Matlab makefile for C++ code.
    ./addPath.m: Adds the sub-directories into the path of Matlab.
    ./demoCtw.m: Alignment of a pair of synthetic sequences by CTW.
    


Other Tips
    For each C++ code, we provide its corresponding Matlab version. For instance, you can use "dtwFordSlow.m" instead of "dtwFord.cpp". They have the same interface in both input and output. The C++ code is faster to obtain result while the Matlab version is easier to understand and debug.



Copyright
    This software is free for use in research projects. If you publish results obtained using this software, please use this citation.
@inproceedings{Zhou_2009_6478,
   author = {Feng Zhou and Fernando de la Torre},
   title = {Canonical Time Warping for Alignment of Human Behavior},
   booktitle = {Neural Information Processing Systems Conference (NIPS)},
   month = {December},
   year = {2009},
}
If you have any question, please feel free to contact Feng Zhou (zhfe99@gmail.com).
