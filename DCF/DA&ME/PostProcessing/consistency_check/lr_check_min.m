% Left-Right Consistency Check

 % INPUT
 %   D1 initial disparity map from left to right
 %   D2 initial disparity map from rigth to left
 %   I1 the left stereo image - Reference Image
 %
 %   D1, D2, and I1 must be provided by the user
 %
 %   threshold - a value greater than 1 to detect occluded pixels
 %
 % OUTPUT
 %   D_filled disparity values filled with minimum value between D1 and D2.
 %   First, it fill in the occluded pixels with the value a valid disparity
 %   in its scanline.
 %
 %   D_occ disparity map which shows occused points
 %
 
 % Reference: 
 % 
 
 % Example
 % [D_filled, D_occ] = lr_check_min(D1,D2,I1,1);
 
 % Prepared by: Gabriel da Silva Vieira (Nov 2017)

function [D_filled, D_occ] = lr_check_min(D1, D2, I1, threshold)

D1(D1<=0) = 1;
D2(D2<=0) = 1;
D1(isnan(D1)) = 1000;
D2(isnan(D2)) = 500;

[h, w, ~] = size(I1);

% Left-right consistency check
Y = repmat((1:h)', [1 w]);
X = repmat(1:w, [h 1]) - D1;
X(X<1) = 1;
indices = sub2ind([h,w],Y,X);

D_occ = D1;
D_occ(abs(D1 - D2(indices)) >= threshold) = -1;

% Fill and filter (post-process) pixels that fail the consistency check
D_filled = fill_min(D_occ);

end