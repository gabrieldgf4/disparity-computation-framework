/* Output statistics about pixels having a value (different from NaN).
    Copyright (C) 2010 Pascal Monasse <monasse@imagine.enpc.fr>

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

#include "libIO/io_tiff.h"
#include <iostream>
#include <cstdlib>

/// Usage: density im_float.tif
/// In the TIFF float image @im_float.tif, count and display to standard output
/// statistics about the number of pixels having a value (different from NaN).
int main(int argc, char** argv)
{
    if(argc != 2) {
        std::cerr << "Usage: " << argv[0] << " im_float.tif" <<std::endl;
        return 1;
    }

    size_t w=0, h=0;
    float* im = read_tiff_f32_gray(argv[1], &w, &h);
    if(! im) {
        std::cerr << "Impossible to read float image " << argv[1] <<std::endl;
        return 1;
    }

    const float* in=im;
    int n=0;
    for(size_t i=w*h; i>0; i--, in++)
        if(*in == *in)
            ++n;
    std::cout << "Density: " << n << " /" << w*h << " = " << 100*n/(w*h) << "%"<<std::endl; 
    
    free(im);
    return 0;
}
