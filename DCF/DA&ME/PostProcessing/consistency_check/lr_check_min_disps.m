% Left-Right Consistency Check

 % INPUT
 %   D1 initial disparity map from left to right
 %   D2 initial disparity map from rigth to left
 %   I1 the left stereo image - Reference Image
 %
 %   D1, D2, and I1 must be provided by the user
 %
 %
 % OUTPUT
 %   D disparity values filled with minimum value between D1 and D2.
 %
 %
 
 % Reference: 
 % 
 
 % Example
 % [D] = lr_check_min_disps(D1,D2,I1);
 
 % Prepared by: Gabriel da Silva Vieira (Nov 2017)

function D = lr_check_min_disps(D1, D2, I1)


D1(isnan(D1)) = 1000;
D2(isnan(D2)) = 500;

[heigth, width, ~] = size(I1);
Y = repmat((1:heigth)', [1 width]);
X = repmat(1:width, [heigth 1]) - D1;
X(X<1) = 1;
indices = sub2ind([heigth,width],Y,X);

D = nanmin(D1,D2(indices));

end