% Maximum Likelihood stereo algorithm

% INPUT
%   I1 the left stereo image
%   I2 the right stereo image
%   min_d minimum disparity
%   max_d maximum disparity
%   method used for calculating the correlation scores
%   Valid values include: 'SAD', 'SSD', 'STAD', 'ZSAD', 'ZSSD', 'SSDNorm', 'NCC',
%   'AFF', 'LIN', 'BTSSD', 'BTSAD', 'TAD_C+G'
%   h, w heigth and width from the Fixed Windows, respectively 
%   reverse used to calc disparity map from left to rigth, input 1 or -1,
%   1 means regular disparity calculation, -1 means reverse disparity
%   calculation
%
%   I1, I2, min_d, max_d, method, h, w, and reverse must be provided by the user
%
%   occ occlusion penalty
%
% OUTPUT
%   dl Disparity Image in Left Image coordinates
%   dr Disparity Image in Right Image coordinates

% Example:
% [dl,dr] = ml(I1,I2,0,15,'SSD',0,0,1,0.0009);

%References
% Cox, Ingemar J., Sunita L. Hingorani, Satish B. Rao, and Bruce M. Maggs. 
% "A maximum likelihood stereo algorithm." Computer vision and image understanding 63, 
% no. 3 (1996): 542-567.
%
% <https://github.com/rajmohanasokan/Dynamic_Programming_Stereo_Matching>

% Prepared by: Gabriel da Silva Vieira, Brazil (May 2017)


function [dl, dr] = ml(I1, I2, min_d, max_d, method, h, w, reverse, occ)


% Execute block_matching to construct the DSI matrix
[~, ~, C1] = block_matching(I1, I2, min_d, max_d, method, h, w, reverse);

% the range of disparity values from min_d to max_d inclusive
d_vals = min_d : max_d;
offsets = length(d_vals);

%I1 = im2double(I1);
%I2 = im2double(I2);

[heigth, width, ~] = size(I1);

% declare variables
dsi = NaN(offsets,width);
temp = NaN(width,width);
C = NaN(width,width);
C(1,1) = 0;
    
 for i = 2:width
    C(i,1) = i*occ;
 end


for row = 1:heigth
   
   % create a dsi structure from block_matching output function
   for i=1:offsets
       dsi(i,:) = C1(row,:,i);
   end
   
  % take each line from dsi and put them in a diagonal way 
  col = 1;
   for i=1:size(dsi,1)
       l1 = i;
       c1 = 1;
       for j=col:size(dsi,2)         
           temp(l1,c1) = dsi(i,j);
           l1 = l1+1;
           c1 = c1+1;
       end
           col = col+1;
   end
           
% Execute the Cox Algorithm   
   dist = 2;
   col = 2; 
   for i = 2:width
    for j = col:dist
        min1 = C(i-1,j-1)+temp(i,j);
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
       
    if i >= offsets+2
        col = col+1;
    else
        col = 2;
    end
    
    dist = dist+1;
    
   end

%Reconstruct the optimum match
i = width;
j = width;
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
clear M
   
end

end
