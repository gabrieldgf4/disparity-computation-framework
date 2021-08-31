
% Detect BRISK features

% Reference
% [1] Leutenegger, S., M. Chli and R. Siegwart. “BRISK: Binary Robust Invariant Scalable Keypoints”, 
% Proceedings of the IEEE International Conference, ICCV, 2011.

function [matchedPoints1, matchedPoints2] = brisk_detector(I1, I2)

if size(I1, 3) == 3
    I1 = rgb2gray(I1);
end

if size(I2, 3) == 3
    I2 = rgb2gray(I2);
end

regionsObj1 = detectBRISKFeatures(I1);
[f1, vpts1] = extractFeatures(I1, regionsObj1);

regionsObj2 = detectBRISKFeatures(I2);
[f2, vpts2] = extractFeatures(I2, regionsObj2);

% Retrieve the locations of matched points.
indexPairs = matchFeatures(f1,f2) ;
matchedPoints1 = vpts1(indexPairs(:,1), :);
matchedPoints2 = vpts2(indexPairs(:,2), :);

% showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2,'montage');
%title('Original images and matching feature points');

end