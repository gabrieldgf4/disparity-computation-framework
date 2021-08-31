% Locally Consistent (LC) Algorithm

 % INPUT
 %   D initial disparity map
 %   I1 the left stereo image - Reference Image
 %   I2 the right stereo image - Target Image
 %
 %   D, I1 and I2 must be provided by the user
 %
 % 
 %   gamma_s a parameter that control the spacial proximity (f,g)
 %   gamma_c control the behavior of color proximity (f,g)
 %   gamma_t control the behavior of two potencial corresponding points
 %   (g,g')
 %   p a value to be truncated
 %   min_d minimum disparity
 %   max_d maximum disparity
 %   dim_x window size in X
 %   dim_y window size in Y
 %
 % OUTPUT
 %   D_out disparity values
 %   acc_plausibility all plausibilities in each disparity
 %
 
 % Reference: Stefano Mattocia. 
 % A locally global approach to stereo correspondence, 2009.
 
 % Example
 % [D_out, acc_plausibility] = lc(D,I1,I2,12,30,25,69,0,15,39,39);
 
 % Prepared by: Gabriel da Silva Vieira, Brazil (Sep 2017)
 
function [D_out, acc_plausibility] = lc(D, I1, I2, gamma_s, gamma_c,...
    gamma_t, p, min_d, max_d, dim_x, dim_y)

D(D<=0) = 1;
D(isnan(D)) = 1;

I1 = double(I1);
I2 = double(I2);

% Prepare bordes 
p_h = (dim_x-1)/2;
p_w = (dim_y-1)/2;

% To avoid ilegal indexes
I1 = padarray(I1, [p_h p_w], NaN);
I2 = padarray(I2, [p_h p_w], NaN);
D = padarray(D, [p_h p_w], NaN);

[height, width, channels] = size(I1);
% To use sum function in an appropriate way
if channels == 1
    dimension = 3;
else
    dimension = channels;
end

% Prepare to Equation (3), spatial proximity
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

% the range of disparity values from min_d to max_d inclusive
d_vals = min_d : max_d;
offsets = length(d_vals);

% The Accumulated Plausibility
acc_plausibility = NaN(height, width, offsets);


for i=p_h+1:height-p_h
    for j=p_w+1:width-p_w
        
        d = D(i,j);
        
        center_p_col_I2 = (j - (d) + (1)); % It is prepared to work in two ways
        
        % To avoid ilegal indexes
        if center_p_col_I2 < (p_w+1) || center_p_col_I2 > (width-p_w)
            continue;
        end
                
        center_point_I1 = I1(i, j, :);

        center_point_I2 = I2(i, center_p_col_I2, :);
        
        % Cut windows - windows of interest
        win_I1 = I1(i-p_h:i+p_h, j-p_w:j+p_w, :);
        win_I2 = I2(i-p_h:i+p_h, center_p_col_I2-p_w:center_p_col_I2+p_w, :);
               
        % Equation (4), color proximity
        diff_from_center_p_I1 = (bsxfun(@minus, center_point_I1, win_I1)).^2;
        diff_from_center_p_I1 = sum(diff_from_center_p_I1, dimension) / channels;
        diff_from_center_p_I1 = sqrt(diff_from_center_p_I1);
        
        % Equation (4), ...
        diff_from_center_p_I2 = (bsxfun(@minus, center_point_I2, win_I2)).^2;
        diff_from_center_p_I2 = sum(diff_from_center_p_I2, dimension) / channels;
        diff_from_center_p_I2 = sqrt(diff_from_center_p_I2);       
        
        % Equation (5), color proximity between two potencial corresponding
        % points
        diff_from_win_I1_I2 = (bsxfun(@minus, win_I1, win_I2)).^2;
        diff_from_win_I1_I2 = sum(diff_from_win_I1_I2, dimension) / channels;
        diff_from_win_I1_I2 = sqrt(diff_from_win_I1_I2);
        
        % To increase robustness (4) and (5) are truncated at p
        diff_from_center_p_I1(diff_from_center_p_I1 > p) = p;
        diff_from_center_p_I2(diff_from_center_p_I2 > p) = p;
        diff_from_win_I1_I2(diff_from_win_I1_I2 > p) = p;
        
        % Equation (6), Plausibility of Points
        P_ = exp(-dist./gamma_s) .* exp(-diff_from_center_p_I1./gamma_c)...
            .* exp(-dist./gamma_s) .* exp(-diff_from_center_p_I2./gamma_c)...
            .* exp(-diff_from_win_I1_I2./gamma_t);
           
        % Acumulate all playsibility off a point by sum
        tmp = cat(3, acc_plausibility(i-p_h:i+p_h, j-p_w:j+p_w, d), P_);
        acc_plausibility(i-p_h:i+p_h, j-p_w:j+p_w, d) = nansum(tmp,3);
                
    end
end
    % to cut borders
    acc_plausibility = acc_plausibility(p_h+1:height-p_h, p_w+1:width-p_w, :);
    
    % WTA strategy
    [C_max_out, D_out] = max(acc_plausibility, [], 3);
end
