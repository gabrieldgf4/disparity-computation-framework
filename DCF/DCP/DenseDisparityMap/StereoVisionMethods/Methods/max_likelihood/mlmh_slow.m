
% Maximum Likelihood, Minimum Horizontal discontinuities stereo algorithm

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

function [dl, dr] = mlmh_slow(I1, I2, occ)

if(size(I1,3)==3)
    I1 = rgb2gray(I1);
    I2 = rgb2gray(I2);
end

I1 = im2double(I1);
I2 = im2double(I2);

[heigth, width] = size(I1);

% Execute the Cox Algorithm 
for row = 1:heigth
   
    C = NaN(width,width);
    Dd = 1000*ones(width,width);
    Dh = 1000*ones(width,width);
    Dv = 1000*ones(width,width);
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
            Dd(i,j) = imin(Dd(i-1,j-1), Dh(i-1,j-1)+1, Dv(i-1,j-1)+1); %Path Tracker
        elseif(cmin==min2)
            Dh(i,j) = imin(Dd(i-1,j)+1, Dh(i-1,j), Dv(i-1,j)+1);
        elseif(cmin==min3)
            Dv(i,j) = imin(Dd(i,j-1)+1, Dh(i,j-1)+1, Dv(i,j-1));
        end
    end
   end

% Reconstruct the optimum match
p = width;
q = width;

switch(imin(Dd(p,q), Dh(p,q), Dv(p,q)))
   
    case 1
        dl(row,p) = abs(p-q);
        %disprigth(row,q) = abs(q-p);
        d1 = 0; d2 = 1; d3 = 1;
        e = 1; f = 1;
    case 2
        dl(row,p) = NaN;
        d1 = 1; d2 = 0; d3 = 1;
        e = 1; f = 0;
    case 3
        dr(row,q) = NaN;
        d1 = 1; d2 = 1; d3 = 0;
        e = 0; f = 1;  
end

while(p>1 && q>1)
    
   switch(imin(Dd((p-e),q-f)+d1, Dh((p-e),q-f)+d2, Dv((p-e),q-f)+d3))
       case 1
           dl(row,p-e) = abs((p-e)-(q-f)); % Disparity Image in Left Image coordinates
           dr(row,q-f) = abs((q-f)-(p-e)); % Disparity Image in Right Image coordinates
           d1 = 0; d2 = 1; d3 = 1;
           p = p-e; q = q-f;
           e = 1; f = 1;
       case 2
           dl(row,p-e) = NaN;
           d1 = 1; d2 = 0; d3 = 1;
           p = p-e; q = q-f;
           e = 1; f = 0;
       case 3
           dr(row,q-f) = NaN;
           d1 = 1; d2 = 1; d3 = 0;
           p = p-e; q = q-f;
           e = 0; f = 1;
   end
end
clear C Dd Dh Dv
   
end

end

function idx = imin(Dd, Dh, Dv)
    d_min = min([Dd,Dh,Dv]);
    if d_min == Dd
        idx = 1;
    elseif d_min == Dh
         idx = 2;
    else
        idx = 3;
    end
end