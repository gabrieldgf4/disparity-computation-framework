% Asymmetric Bilateral Support Weigth Function

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
 %   gamma_c a constant of color similarity
 %   gamma_p a constant of proximity similarity
 %   dim_x window size in X
 %   dim_y window size in Y
 %
 % OUTPUT
 %   D disparity values
 %   C_min cost associated with the minimum disparity at pixel (i,j)
 %
 
 % Reference: 
 % Asmaa Hosni; Michael Bleyer; Margrit Gelautz. Secrets of adaptive
 % support weight techniques for local stereo matching, 2013. 
 
 % Example
 % [D, C_min] = bl_asym(I1,I2,0,15,'SAD',0,0,1,7,36,33,33);
 
 % Prepared by: Gabriel da Silva Vieira, Brazil (Nov 2017)
 
function [D, C_min] = bl_asym(I1, I2, min_d, max_d, method,  h, w, ...
    reverse, gamma_c, gamma_p, dim_x, dim_y)

I1 = double(I1);
I2 = double(I2);

% the range of disparity values from min_d to max_d inclusive
d_vals = min_d : max_d;
offsets = length(d_vals);

%%%% Spatial proximity of a neighboring pixel %%%%
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

%%%% the perceptual proximity strength
proximity = (dist./gamma_p);
%%%%

% Prepare bordes 
p_h = (dim_x-1)/2;
p_w = (dim_y-1)/2;

%%%% Correspondence Algorithm by using the Block Matching
[~, ~, C] = block_matching(I1,I2,min_d,max_d,method,h,w,reverse);
%%%%

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
E = NaN(height, width, offsets); 

%%%% For each point(i,j), analise the similary between the two stereo images
for i=p_h+1:height-p_h
    for j=p_w+1:width-p_w
                
        center_point_I1 = I1(i, j, :);

        win_I1 = I1(i-p_h:i+p_h, j-p_w:j+p_w, :);
      
        % color similarity 
        diff_from_center_p_I1 = (bsxfun(@minus, center_point_I1, win_I1)).^2;
        diff_from_center_p_I1 = sum(diff_from_center_p_I1, dimension) / channels;
        diff_from_center_p_I1 = sqrt(diff_from_center_p_I1);
        
         % color similarity grouping
        color_group_I1 = (diff_from_center_p_I1./gamma_c);
        
        % Equation (6), support weight window
        W_I1 = exp(-(color_group_I1 + proximity));
        
        win_C = C(i-p_h:i+p_h, j-p_w:j+p_w, :);
        
        % Equation (17), The Dissimilarity Cost
        E(i,j,:) = sum(nansum(bsxfun(@times, win_C, W_I1))) / sum(nansum(W_I1));       
    end
end

    % to cut borders
    E = E(p_h+1:height-p_h, p_w+1:width-p_w, :);
   
    % WTA strategy
    [C_min, D] = min(E, [], 3);
    
end
