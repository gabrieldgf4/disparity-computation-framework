/* A contrario block matching for disparity computation.
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

#ifndef STEREOAC_H
#define STEREOAC_H

#include "libLWImage/LWImage.h"

void stereoAC(LWImage<float> im1, LWImage<float> im2, LWImage<float> PCs,
              int minDisp, int maxDisp, float epsNFA,
              float* dispInc, float* dispMax=0);

#endif
