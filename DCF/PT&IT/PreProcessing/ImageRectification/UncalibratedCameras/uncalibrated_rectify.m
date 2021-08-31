
% Rectify image pairs
%
% I1 - left image
% I2 - right image
%
% I1 and I2 must be provided by the user

function [out1, out2] = uncalibrated_rectify(I1, I2)

I1 = rgb2gray(I1);
I2 = rgb2gray(I2);

% Find the Harris features.
points1 = detectHarrisFeatures(I1);
points2 = detectHarrisFeatures(I2);

% Extract the features.
[f1,vpts1] = extractFeatures(I1,points1);
[f2,vpts2] = extractFeatures(I2,points2);

% Retrieve the locations of matched points.
indexPairs = matchFeatures(f1,f2) ;
matchedPoints1 = vpts1(indexPairs(:,1), :);
matchedPoints2 = vpts2(indexPairs(:,2), :);

% Compute the fundamental matrix from the corresponding points.
f = estimateFundamentalMatrix(matchedPoints1,matchedPoints2,...
    'Method','Norm8Point');

% Compute the rectification transformations.
[t1, t2] = estimateUncalibratedRectification(f,matchedPoints1,...
    matchedPoints2,size(I2));

% Rectify the stereo images using projective transformations t1 and t2.
[out1, out2] = rectifyStereoImages(I1,I2,t1,t2);


end