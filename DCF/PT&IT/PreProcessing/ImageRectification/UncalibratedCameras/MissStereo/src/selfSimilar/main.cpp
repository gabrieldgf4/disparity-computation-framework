/* Self-similarity disparity filter.
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

#include "selfSimilar.h"

#include "libIO/io_tiff.h"
#include "libIO/io_png.h"

#include <cmath>
#include <iostream>
#include <sstream>
#include <cassert>

/// Radius min of window to evaluate self-similarity.
static const int MIN_LOOK_RADIUS=8;

/// PNG and TIFF formats
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

/// Radius of window patch.
static int size_window() {
#include "dataStereo/pca_basis.dat"
    int psize = sizeof(pca)/sizeof(*pca);
 	int win = (int)sqrtf((float)psize);
	win = (win-1) / 2;
    assert((2*win+1)*(2*win+1) == psize);
    return win;
}

/// Usage: selfSimilar imgIn imgIn2 dispmin dispmax dispMapIn dispMapOut [ratio_max]
/// Filter out self-similar blocks in TIFF float disparity map @dispMapIn,
/// output in @dispMapOut (so there are more NaN pixels). The rectified images
/// are @imgIn and @imgIn2 (PNG or TIFF format) and the disparity range given by
/// @dMin and @dMax (integer values). @ratio_max, if given, is the Lowe ratio
/// parameter (positive float value), the default is 1.
int main(int argc, char** argv)
{
    if(argc != 7 && argc != 8) {
        std::cerr << "Usage: " << argv[0] << " imgIn imgIn2 dMin dMax dispMapIn dispMapOut [ratio_max]" << std::endl;
        return 1;
    }

    LWImage<float> im1(0,0,0), im2(0,0,0), disp(0,0,0);
    if(!(loadImage(argv[1],im1) &&
         loadImage(argv[2],im2) &&
         loadImage(argv[5],disp)))
        return 1;
    assert(im1.w==disp.w && im1.h==disp.h);

    int dispMin, dispMax;
    std::istringstream f(argv[3]), g(argv[4]);
    if(! ((f>>dispMin).eof() && (g>>dispMax).eof())) {
        std::cerr << "Unable to read disparity bounds" << std::endl;
        return 1;
    }
    float ratio=1.0f;
    if(argc > 7) {
        std::istringstream h(argv[7]);
        if(! (h>>ratio).eof()) {
            std::cerr << "Unable to read ratio_max" << std::endl;
            return 1;
        }   
    }

    const int lookr = std::min(MIN_LOOK_RADIUS, (dispMax-dispMin)/2);
    selfSimilarFilter(im1, im2, lookr, size_window(), disp.data, ratio);
    write_tiff_f32(argv[6], disp.data, disp.w, disp.h, 1);

    free(im1.data);
	free(im2.data);
    free(disp.data);

    return 0;
}
