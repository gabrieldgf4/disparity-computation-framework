
% Maximum Likelihood stereo algorithm

% INPUT
%   I1 the left stereo image
%   I2 the right stereo image
%   occ occlusion penalty
%
% OUTPUT
%   dl Disparity Image in Left Image coordinates
%   dr Disparity Image in Right Image coordinates

%References
% Cox, Ingemar J., Sunita L. Hingorani, Satish B. Rao, and Bruce M. Maggs. 
% "A maximum likelihood stereo algorithm." Computer vision and image understanding 63, 
% no. 3 (1996): 542-567.
%
% <https://github.com/rajmohanasokan/Dynamic_Programming_Stereo_Matching>

% Prepared by: Gabriel da Silva Vieira (Mar 2017)

function [dl, dr] = ml_slow(I1, I2, occ)

if(size(I1,3)==3)
    I1 = rgb2gray(I1);
    I2 = rgb2gray(I2);
end

I1 = im2double(I1);
I2 = im2double(I2);

[height, width] = size(I1);

% Execute the Cox Algorithm 
for row = 1:height
   
    C = NaN(width,width);
    C(1,1) = 0;
    
   for i = 2:width
    C(i,1) = i*occ;
   end
   for j = 2:width
    C(1,j) = j*occ; 
   end 
   
   for i = 2:width
       
    for j = 2:width
        temp = (I1(row,i)-I2(row,j))^2;

        min1 = C(i-1,j-1)+temp;
        min2 = C(i-1,j)+occ;
        min3 = C(i,j-1)+occ;
        cmin = min([min1,min2,min3]);
        C(i,j) = cmin; % Cost Matrix
        if(cmin==min1)
            M(i,j) = 1; %Path Tracker
        elseif(cmin==min2)
            M(i,j) = 2;
        elseif(cmin==min3)
            M(i,j) = 3;
        end
    end
   end

i = width;
j = width;

%Reconstruct the optimum match

while(i~=1 && j~=1)
    
   switch M(i,j)
       case 1
           dl(row,i) = abs(i-j); % Disparity Image in Left Image coordinates
           dr(row,j) = abs(j-i); % Disparity Image in Right Image coordinates
           i = i-1;
           j = j-1;
       case 2
           dl(row,i) = NaN;
           i = i-1;
       case 3
           dr(row,j) = NaN;
           j = j-1;
   end
end
clear C M
   
end

end