/* ORSA (Optimized RANSAC): filter out outlier matches.
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

#ifndef ORSA_H
#define ORSA_H

#include "libMatch/match.h"
#include "libNumerics/matrix.h"

libNumerics::matrix<float>
orsa(const std::vector<Match>& match,
     int t, bool verb, int mode, bool stop, float logalpha0,
     std::vector<size_t>& inliers, float& errorMax);

#endif
