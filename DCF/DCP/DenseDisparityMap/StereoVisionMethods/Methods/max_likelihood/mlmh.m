% Maximum Likelihood, Minimum Horizontal discontinuities stereo algorithm

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
% [dl,dr] = mlmh(I1,I2,0,15,'SSD',1,1,1,0.0009);

%References
% Cox, Ingemar J., Sunita L. Hingorani, Satish B. Rao, and Bruce M. Maggs. 
% "A maximum likelihood stereo algorithm." Computer vision and image understanding 63, 
% no. 3 (1996): 542-567.
%
% <https://github.com/rajmohanasokan/Dynamic_Programming_Stereo_Matching>

% Prepared by: Gabriel da Silva Vieira, Brazil (May 2017)


function [dl, dr] = mlmh(I1, I2, min_d, max_d, method, h, w, reverse, occ)

if strcmp(method, "TAD_C+G") || strcmp(method, "BTSAD") || strcmp(method, "SAD") ...
        || strcmp(method, "STAD")
    I1 = im2double(I1);
    I2 = im2double(I2);
end

% Execute block_matching to construct the DSI matrix
[~, ~, C1] = block_matching(I1, I2, min_d, max_d, method, h, w, reverse);

% the range of disparity values from min_d to max_d inclusive
d_vals = min_d : max_d;
offsets = length(d_vals);

[heigth, width, ~] = size(I1);

% declare variables
dsi = NaN(offsets,width);
temp = NaN(width,width);
C = NaN(width,width);
C(1,1) = 0;
    
for i = 2:width
   C(i,1) = i*occ;
end

% Execute the Cox Algorithm
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
    
    Dd = realmax*ones(width,width); % realmax is the largest finite floating-point number in IEEE® double precision
    Dh = realmax*ones(width,width);
    Dv = realmax*ones(width,width);
    
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
            Dd(i,j) = imin(Dd(i-1,j-1), Dh(i-1,j-1)+1, Dv(i-1,j-1)+1); %Path Tracker
        elseif(cmin==min2)
            Dh(i,j) = imin(Dd(i-1,j)+1, Dh(i-1,j), Dv(i-1,j)+1);
        elseif(cmin==min3)
            Dv(i,j) = imin(Dd(i,j-1)+1, Dh(i,j-1)+1, Dv(i,j-1));
        end
    end
    
    if i >= offsets+2
        col = col+1;
    else
        col = 2;
    end
    
    dist = dist+1;
    
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
clear Dd Dh Dv
   
end

end

% It returns the index, (1, 2, or 3) to the minimum value.
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
