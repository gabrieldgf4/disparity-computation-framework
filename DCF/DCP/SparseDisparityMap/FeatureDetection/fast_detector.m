
% Detect FAST features

% Reference
% [1] Rosten, E., and T. Drummond. "Fusing Points and Lines for High Performance Tracking," 
% Proceedings of the IEEE International Conference on Computer Vision, 
% Vol. 2 (October 2005): pp. 1508–1511.

function [matchedPoints1, matchedPoints2] = fast_detector(I1, I2)

if size(I1, 3) == 3
    I1 = rgb2gray(I1);
end

if size(I2, 3) == 3
    I2 = rgb2gray(I2);
end

regionsObj1 = detectFASTFeatures(I1);
[f1, vpts1] = extractFeatures(I1, regionsObj1);

regionsObj2 = detectFASTFeatures(I2);
[f2, vpts2] = extractFeatures(I2, regionsObj2);

% Retrieve the locations of matched points.
indexPairs = matchFeatures(f1,f2) ;
matchedPoints1 = vpts1(indexPairs(:,1), :);
matchedPoints2 = vpts2(indexPairs(:,2), :);

% showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2,'montage');
%title('Original images and matching feature points');

end