/* Median inpainting.
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

#include "median_disparity.h"

#include "libIO/io_tiff.h"
#include "libLWImage/LWImage.h"

#include <iostream>

static bool loadImage(const char* name, LWImage<float>& im) {
    size_t nx, ny;
    im.data = read_tiff_f32_gray(name, &nx, &ny);
    im.w = nx; im.h = ny;
    if(! im.data)
        std::cerr << "Unable to load image file " << name << std::endl;
    return (im.data!=0);
}

/// Usage: medianFill imgIn imgOut
/// Fill some NaN pixels in TIFF float image @imgIn by median filter. Output in
/// @imgOut.
int main (int argc, char** argv)
{
    if(argc != 3) {
        std::cerr << "Usage: " << argv[0] << " imgIn imgOut" << std::endl;
        return 1;
    }

    LWImage<float> im(0,0,0);
    if(! loadImage(argv[1],im))
        return 1;

    std::cout << "Median Filter..." <<std::endl;

    float* fill = new float[im.w*im.h];   

    median_disp(im.data, fill, 1, im.w, im.h);
    write_tiff_f32(argv[2], fill, im.w, im.h, 1);

    free(im.data);
    delete [] fill;

    return 0;
}
