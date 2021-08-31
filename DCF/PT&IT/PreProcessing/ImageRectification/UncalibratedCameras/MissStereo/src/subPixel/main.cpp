/* Sub-pixel disparity map refinement.
    Copyright (C) 2008,2009 Neus Sabater <neussabater@gmail.com>
    Copyright (C) 2010,2011 Pascal Monasse <monasse@imagine.enpc.fr>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "subpixel.h"

#include "libIO/io_tiff.h"
#include "libIO/io_png.h"
#include "libLWImage/LWImage.h"

#include <iostream>
#include <cassert>

/*-- VARIABLES --*/
static const int NWIN = 4;

static bool loadImage(const char* name, LWImage<float>& im) {
    size_t nx, ny;
    std::string sname(name);
    size_t pos = sname.rfind('.');
    if(pos != std::string::npos)
        sname = sname.substr(pos+1);
    if(sname == "png")
        im.data = read_png_f32_gray(name, &nx, &ny);
    if(! im.data)
        im.data = read_tiff_f32_gray(name, &nx, &ny);
    im.w = nx; im.h = ny;
    if(! im.data)
        std::cerr << "Unable to load image file " << name << std::endl;
    return (im.data!=0);
}

/// Usage: subPixel imgIn imgIn2 dispMapIn dispMapOut
/// Refine disparity map @dispMapIn with subpixel accuracy, output in
/// @dispMapOut (TIFF float images). Rectified input images are in files @imgIn
/// and @imgIn2 (PNG or TIFF format).
int main (int argc, char** argv)
{
    if(argc != 5) {
        std::cerr << "Usage: " << argv[0] << " imgIn imgIn2 dispMapIn dispMapOut" << std::endl;
        return 1;
    }

    LWImage<float> im1(0,0,0), im2(0,0,0), disp(0,0,0);
    if(!(loadImage(argv[1],im1) &&
         loadImage(argv[2],im2) &&
         loadImage(argv[3],disp)))
        return 1;

    std::cout << "Subpixel refinement..." <<std::endl;

#include "dataStereo/prolate.dat"
    assert((4*NWIN+1)*(4*NWIN+1) == sizeof(prolate)/sizeof(*prolate));

    float* subDisp = new float[im1.w*im1.h];   

    refine_subpixel_accuracy(im1.data, im2.data, disp.data, subDisp,
                             prolate,4*NWIN+1, im1.w,im1.h, im2.w,im2.h);
    write_tiff_f32(argv[4], subDisp, im1.w, im1.h, 1);

    free(im1.data);
	free(im2.data);
	free(disp.data);
	delete [] subDisp;

    return 0;
}
