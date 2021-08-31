% MissStereo: a binocular stereo pipeline

# ABOUT

* Authors : Toni Buades <toni.buades@uib.es>
            Julie Digne <jdigne@gmail.com>
            Nicolas Limare <nicolas.limare@cmla.ens-cachan.fr>
            Lionel Moisan <Lionel.Moisan@parisdescartes.fr>
            Pascal Monasse <monasse@imagine.enpc.fr>
            Neus Sabater <neussabater@gmail.com>
            Zhongwei Tang <tangfrch@gmail.com>
* Copyright : (C) 2010-2011 IPOL Image Processing On Line http://www.ipol.im/
* License : GPL v3+, see file LICENSE.txt

# OVERVIEW

This source code provides a binocular stereo pipeline, in two main steps:
     - Epipolar rectification (Fusiello-Irsara algorithm)
     - Disparity map computation (Sabater-Almansa-Morel algorithm)

The input is composed of an image pair in PNG format.
The output is the epipolar rectified images and a disparity map in float TIFF format.

# REQUIREMENTS

The code is written in ANSI C++, and should compile on any system with
an ANSI C++ compiler.

The libpng header and libraries are required on the system for
compilation and execution. See http://www.libpng.org/pub/png/libpng.html

The libtiff header and libraries are required on the system for
compilation and execution. See http://www.remotesensing.org/libtiff/

# BUILD

See file BUILD.txt for instructions.

# USAGE

Each logical step of the algorithm is compiled in an independent executable
program. Scripts files provided in a seperate folder implement the pipeline.

See doc/userguide.pdf for complete instructions.

# MAINTENANCE

If you think you have found a bug, contact Pascal Monasse <monasse@imagine.enpc.fr>
