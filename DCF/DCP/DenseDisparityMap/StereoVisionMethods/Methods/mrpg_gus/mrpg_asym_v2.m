% Asymmetric Multi-resolution and Perceptual Grouping Algorithm
% This code doesn't consider the pyrimides levels

% INPUT
%   I1 the left stereo image - Reference Image
%   I2 the right stereo image - Target Image
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
%   pyr_levels number of levels in the pyramid
%   gamma_s a constant of color similarity
%   kernel is applied when reduce resolution
%   Tmax neighboring disparities
%   dim_x window size in X
%   dim_y window size in Y
%
% OUTPUT
%   D disparity values
%   all_maps disparity maps from each level of the pyramid
%
 
 % Reference: Gustavo Teodoro Laureano, Maria Stela Veludo de Paiva. 
 % Disparities Maps Generation Employing Multi-resolution Analysis and 
 % Perceptual Grouping, 2008
 
 % Example
 % [D, all_maps] = mrpg_asym_v2(I1,I2,0,15,'TAD_C+G',1,1,1,3,9,[1 1;1 1],6,35,35);
 
 % Prepared by: Gabriel da Silva Vieira, Brazil (Nov 2017)
 
function [D, all_maps] = mrpg_asym_v2(I1, I2, min_d, max_d, method, h, w,...
    reverse, pyr_levels, gamma_s, kernel, Tmax, dim_x, dim_y)

gamma_p = dim_x/2; % half of window dimension
half_Tmax = fix(Tmax/2); % to take neigboors from a considered disparity
norm_kernel = sum(nansum(kernel));

% the range of disparity values from min_d to max_d inclusive
d_vals = min_d : max_d;
offsets = length(d_vals);

% Make Pyramid
I1_ = double(I1);
I2_ = double(I2);
Pyr_I1{1} = I1_;
Pyr_I2{1} = I2_;
Pyr_range(1) = offsets; % max disparity for each level

for l=2:pyr_levels
    I1_ = convn(I1_, kernel/norm_kernel, 'same'); % Reduce resolution
    I1_ = I1_(1:2:end, 1:2:end, :); % Reduce sampling
    Pyr_I1{l} = I1_;
    
    I2_ = convn(I2_, kernel/norm_kernel, 'same'); % Reduce resolution
    I2_ = I2_(1:2:end, 1:2:end, :); % Reduce sampling
    Pyr_I2{l} = I2_;
    
    Pyr_range(l) = round( offsets/(2^(l-1)) ); % max disparity for each level
end

%%%% Prepare to Equation (3), spatial proximity of a neighboring pixel %%%%
area_win = dim_x*dim_y;
vector_points = NaN(area_win,2);
lin = dim_x;
cont = 1;
for i=1:dim_x:area_win
    vector_points(i:lin,1) = cont;
    vector_points(i:lin,2) = 1:dim_x;
    lin = lin+dim_x;
    cont = cont+1;
end
% Euclidean Distance
point_in_center = round(length(vector_points)/2);
dist = sqrt((vector_points(point_in_center, 1) - vector_points(:,1)).^2 + ...
    (vector_points(point_in_center, 2) - vector_points(:,2)).^2);

dist = reshape(dist',dim_x,dim_y); 
%%%%

%%%% Equation (4), the perceptual proximity strength
proximity = exp(-dist./gamma_p);
%%%%

% Prepare bordes 
p_h = (dim_x-1)/2;
p_w = (dim_y-1)/2;

%%%% For each one of the pyramid level do same calculus 
for l=pyr_levels:-1:1
    
I1 = Pyr_I1{l};
I2 = Pyr_I2{l};
max_disp = Pyr_range(l);

%%%% Correspondence Algorithm by using the Block Matching
[~, ~, C] = block_matching(I1,I2,min_d,max_disp,method,h,w,reverse);
%%%%

if isequal(reverse, -1)
    I1 = I2;
end

% To avoid ilegal indexes
I1 = padarray(I1, [p_h p_w], NaN);
C = sqrt(padarray(C, [p_h p_w], NaN));

% I1 dimensions
[height, width, channels] = size(I1);
% To use sum function in an appropriate way
if channels == 1
    dimension = 3;
else
    dimension = channels;
end

% Dissimilarity Cost
E = NaN(height, width, max_disp+1); 

%%%% For each point(i,j), analise the similary between the two stereo images
for i=p_h+1:height-p_h
    for j=p_w+1:width-p_w
                
        center_point_I1 = I1(i, j, :);

        win_I1 = I1(i-p_h:i+p_h, j-p_w:j+p_w, :);
      
        % Equation (1), color similarity 
        diff_from_center_p_I1 = (bsxfun(@minus, center_point_I1, win_I1)).^2;
        diff_from_center_p_I1 = sum(diff_from_center_p_I1, dimension) / channels;
        diff_from_center_p_I1 = sqrt(diff_from_center_p_I1);
        
         % Equation (2), color similarity grouping
        color_group_I1 = exp(-diff_from_center_p_I1./gamma_s);
        
        % Equation (6), support weight window
        W_I1 = (color_group_I1 .* proximity);
        
        win_C = C(i-p_h:i+p_h, j-p_w:j+p_w, :);
        
        % Equation (8), The Dissimilarity Cost
        E(i,j,:) = sum(nansum(bsxfun(@times, win_C, W_I1))) / sum(nansum(W_I1));
               
    end
end

    % to cut borders
    E = E(p_h+1:height-p_h, p_w+1:width-p_w, :);
   
    % WTA strategy
    [C_min, D] = min(E, [], 3);
    
    all_maps{l} = D;
    
    D = D-1;
    D( D == 0 ) = 1;
    
    
    if l ~= 1
        D = round((imresize(D, 2)) .* 2); % Expand the disparity map
    end
end
end
