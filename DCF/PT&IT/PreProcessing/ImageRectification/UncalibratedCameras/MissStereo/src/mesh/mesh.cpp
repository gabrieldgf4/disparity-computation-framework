/* PLY file generation as colored point cloud.
    Copyright (C) 2010 Julie Digne <jdigne@gmail.com>
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

#include "libNumerics/matrix.h"
#include <iostream>
#include <cstdlib>
#include <fstream>
#include <vector>
#include <cfloat>
#include <cassert>

#include "libIO/io_tiff.h"
#include "libIO/io_png.h"

using namespace std;
using std::ofstream;

/// To use binary file format (more compact)
static const bool BINARY=true;
/// Separator between fields in ASCII output
static const char SEP='\t';

// Uncomment next line to output a triangulation
//#define TRIANGULATION

/** Build a mesh from a disparity map:
- input: a float TIFF image (a disparity map)
- output: a mesh in PLY file format
PLY file format can be read by paraview and meshlab.
All modelers can also read PLY (blender, ogre...)
More info on PLY: http://www.cc.gatech.edu/projects/large_models/ply.html
*/

/// 3D point and index of each pixel whose disparity has been computed
struct Point{
    int x;
    int y;
    float z;
    int index;
    Point(): x(-1), y(-1), z(-1.0f), index(-1) {}
};

/// Triangle containing the indices of the triangle vertices
struct Triangle{
  int i;
  int j;
  int k;
};

/// Collect all points with disparity and record min and max disparities.
static int collect_points(const float* img, size_t nx, size_t ny,
                          vector<Point>& points, float& min, float& max) {
    int index=0;
    const float *px=img;
    max=-FLT_MAX;
    min=+FLT_MAX;
    for(size_t y=0; y<ny; y++)
        for(size_t x=0; x<nx; x++, px++) {
            Point pt;
            if(*px==*px) {
                pt.x=x;
                pt.y=y;
                pt.z=*px;
                pt.index=index++;
                // Record highest and lowest disparity values
                if(pt.z<min) min=pt.z;
                if(pt.z>max) max=pt.z;
            }
            points.push_back(pt);
        }
    return index;
}

#ifdef TRIANGULATION
/// Naive triangulation of the point cloud
static void triangulate(vector<Point>& points, vector<Triangle>& triangles) {
    for(size_t y=0; y+1<ny; y++) {
        vector<Point>::const_iterator it=points.begin()+y*nx;
        vector<Point>::const_iterator it2=it+nx;
        for(size_t x=0; x+1<nx; ++x, ++it, ++it2) {
            if(it->index!=-1 && (it+1)->index!=-1 && it2->index!=-1) {
                Triangle tr;
                tr.i=it->index;
                tr.j=(it+1)->index;
                tr.k=it2->index;
                triangles.push_back(tr);
            }
            if((it2+1)->index!=-1 && (it+1)->index!=-1 && it2->index!=-1) {
                Triangle tr;
                tr.i=(it2+1)->index;
                tr.j=(it+1)->index;
                tr.k=it2->index;
                triangles.push_back(tr);
            }
        }
    }
}
#endif

/// Find endianness of the system
static std::string endian() {
    int i=0;
    *((unsigned char*)&i)=1;
    return (i==1? "little_endian": "big_endian");
}

/// Write header of PLY file
static void write_ply_header(ostream& out, size_t npts, size_t ntri) {
    out<<"ply"<<endl;
    if(BINARY)
        out<<"format binary_" << endian() << " 1.0"<<endl;
    else
        out<<"format ascii 1.0"<<endl;
    out<<"comment created by MissStereo mesh"<<endl;
    out<<"element vertex "<<npts<<endl;
    out<<"property float x"<<endl;
    out<<"property float y"<<endl;
    out<<"property float z"<<endl;
    out<<"property uchar red"<<endl;
    out<<"property uchar green"<<endl;
    out<<"property uchar blue"<<endl;
    if(ntri>0) {
        out<<"element face "<<ntri<<endl;
        out<<"property list uchar int vertex_index"<<endl;
    }
    out<<"end_header"<<endl;
}

/// Usage: mesh disp_f32.tif image.png out.ply [K_left K_right]
/// Output in PLY file @out.ply the colored point cloud with z coordinate
/// computed from input disparity map @disp_f32.tif (TIFF float image) and
/// color taken from @image.png (PNG format). Normally, the calibration matrices
/// of the stereo pair are given in @K_left and K_right (Matlab text format).
/// Such matrices are evaluated in Fusiello and Irsara's rectification method.
/// If they are not given, a point cloud is still output but the z range is not
/// accurate.
int main(int argc, char **argv) {
    if(argc!=4 && argc!=6) {
        cerr<<"Usage: " <<argv[0] <<" disp_f32.tif image.png out.ply"
            << " [K_left K_right]" <<endl;
        return EXIT_FAILURE;
    }

    // Read images
    size_t nx, ny;
    float* img = read_tiff_f32_gray(argv[1], &nx, &ny);
    if (NULL == img) {
        cerr<<"failed to read the image "<<argv[1]<<endl;
        return EXIT_FAILURE;
    }

    size_t nx2, ny2;
    unsigned char* red = read_png_u8_rgb(argv[2], &nx2, &ny2);
    if(NULL == red) {
        cerr<<"failed to read the image "<<argv[2]<<endl;
        return EXIT_FAILURE;
    }
    unsigned char* green=red+nx2*ny2;
    unsigned char* blue=green+nx2*ny2;

    if(nx != nx2 || ny != ny2) {
        cerr<<"Error: images "<<argv[1]<< " and "<<argv[2]
            << " must have same size"<<endl;
        return EXIT_FAILURE;
    }

    vector<Point> points;
    float min, max;
    int npts = collect_points(img, nx, ny, points, min, max);
    free(img);
 
    // Read calibration matrices if available
    libNumerics::matrix<float> Kl(3,3), Kr(3,3);    
    if(argc > 5) {
        std::ifstream fl(argv[4]), fr(argv[5]);
        if(! fl.is_open() || (fl>>Kl).fail()) {
            cerr<<"failed reading matrix Kl in file "<<argv[4]<<endl;
            return EXIT_FAILURE;
        }
        if(! fr.is_open() || (fr>>Kr).fail()) {
            cerr<<"failed reading matrix Kr in file "<<argv[5]<<endl;
            return EXIT_FAILURE;
        }
        // Normalization
        Kl /= Kl(2,2);
        Kr /= Kr(2,2);
        Kl = Kl.inv();
        /// Check consistency
        libNumerics::matrix<float> v = (Kr*Kl).row(0);
        float min2=+FLT_MAX;
        float max2=-FLT_MAX;

        float x=0,y=0, z;
        z= x-(v(0)*x+v(1)*y+v(2));
        if(z<min2) min2=z; 
        if(z>max2) max2=z;

        x=(float)nx,y=0;
        z= x-(v(0)*x+v(1)*y+v(2));
        if(z<min2) min2=z; 
        if(z>max2) max2=z;

        x=0,y=(float)ny;
        z= x-(v(0)*x+v(1)*y+v(2));
        if(z<min2) min2=z; 
        if(z>max2) max2=z;

        x=(float)nx,y=(float)ny;
        z= x-(v(0)*x+v(1)*y+v(2));
        if(z<min2) min2=z; 
        if(z>max2) max2=z;

        if(max+max2 < 0) { // All negative depths, must correct
            Kl = -Kl;
            Kr = -Kr;
        } else if(min+min2 > 0) { // All positive, OK
        } else { // Change of sign, there is a problem
            cout << "Warning: problem with negative depths => "
                 << "ignoring calibration matrices" <<endl;
            argc = 3;
        }
    }

    vector<Triangle> triangles;
#ifdef TRIANGULATION
    triangulate(points, triangles);
#endif

    // Initialize the ply file by writing the ply header
    ofstream out(argv[3]);
    write_ply_header(out, npts, triangles.size());

    vector<Point>::const_iterator it=points.begin();
    const float d0=nx;
    const float deltaZ = nx/4.0f; // /10.0f;
    const float a=deltaZ/(1.0/d0 - 1.0/(max-min+d0));
    const float z0=deltaZ-a/d0;
    for(; it!=points.end(); ++it)
        if(it->index!=-1) {
            float x=static_cast<float>(it->x);
            float y=static_cast<float>(ny-it->y-1);
            float z = a/(it->z-min+d0)+z0;
            if(argc > 5) { // K matrices known
                libNumerics::vector<float> v(3);
                v(0)=it->x; v(1)=it->y; v(2)=1.0f;
                v = Kl*v;
                z = Kr(0,0)/(x+it->z-(Kr*v)(0));
                x = z*v(0);
                y = z*v(1);
            }
            size_t i=it->y*nx+it->x;
            if(BINARY) {
                assert(sizeof(float)==4 && sizeof(unsigned char)==1);
                out.write((const char*)&x,4)
                   .write((const char*)&y,4)
                   .write((const char*)&z,4);
                out.write((const char*)&red[i],1)
                   .write((const char*)&green[i],1)
                   .write((const char*)&blue[i],1);
            } else
                out << x<<SEP<<y<<SEP<<z <<SEP
                    <<(int)red[i]<<SEP<<(int)green[i]<<SEP<<(int)blue[i]<<endl;
        }

#ifdef TRIANGULATION
    //...and the triangles
    vector<Triangle>::const_iterator itt=triangles.begin();
    for(; itt!=triangles.end(); ++itt)
        if(BINARY) {
            assert(sizeof(int)==4);
            const unsigned char c=3;
            out.write((const char*)&c,1)
               .write((const char*)&itt->i,4)
               .write((const char*)&itt->j,4)
               .write((const char*)&itt->k,4);
        } else
            out<<3<<SEP<<itt->i<<SEP<<itt->j<<SEP<<itt->k<<endl;
#endif

    out.close();
    return EXIT_SUCCESS;
}
