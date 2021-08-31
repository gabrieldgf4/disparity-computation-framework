% Left-Right Consistency Check

 % INPUT
 %   D1 initial disparity map from left to right
 %   D2 initial disparity map from rigth to left
 %   I1 the left stereo image - Reference Image
 %   min_d minimum disparity
 %   max_d maximum disparity
 %
 %   D1, D2, I1, min_d and max_d must be provided by the user
 %
 %   threshold - a value greater than 1 to detect occluded pixels
 %   gamma_c parameter to adjust spatial and color similarity in eq. (6)
 %   gamma_d parameter to adjust spatial and color similarity in eq. (6)
 %   r_median filter dimension of weighted median, has size r_median \times
 %   r_median in eq. (6)
 %
 % OUTPUT
 %   D_filled disparity values filled with a weighted bilateral filter
 %   D_occ disparity map which shows occlused points
 %
 
 % Reference: 
 % C. Rhemann, A. Hosni, M. Bleyer, C. Rother, M. Gelautz, 
 % Fast Cost-Volume Filtering for Visual Correspondence and Beyond, CVPR11
 
 % Example
 % [D_filled, D_occ] = lr_check(D1,D2,I1,0,15,1,0.1,9,19);
 
 % Prepared by: Gabriel da Silva Vieira, Brazil (Nov 2017)

function [D_filled, D_occ] = lr_check(D1, D2, I1, min_d, max_d, threshold, gamma_c, gamma_d, r_median)

D1(D1<=0) = 1;
D2(D2<=0) = 1;
D1(isnan(D1)) = 1000;
D2(isnan(D2)) = 500;

[h, w, ~] = size(I1);

% the range of disparity values from min_d to max_d inclusive
d_vals = min_d : max_d;
offsets = length(d_vals);

% Left-right consistency check
Y = repmat((1:h)', [1 w]);
X = repmat(1:w, [h 1]) - D1;
X(X<1) = 1;
indices = sub2ind([h,w],Y,X);

% check if the difference between D1 and D2 is greater than 1
D_occ = D1;
D_occ(abs(D1 - D2(indices)) >= threshold) = -1;

% Fill and filter (post-process) pixels that fail the consistency check
inputLabels = D_occ;
D_filled = fillPixelsReference(double(I1)/255, inputLabels, gamma_c, gamma_d, r_median, offsets);

end
