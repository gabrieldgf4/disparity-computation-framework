
% Compute the projective matrices between camera 1 and camera 2
%
% I1 - left image
% I2 - right image
% cameraParams - intrinsic parameter matrix from camera

function [camMatrix1, camMatrix2] = projective_matrices(I1, I2, cameraParams) 

% Detect feature points
% Harris-Stephens algorithm.
% returns a cornerPoints object,
% POINTS, containing information about the feature points detected in a
% 2-D grayscale image I, using the minimum eigenvalue algorithm developed
% by Shi and Tomasi.
imagePoints1 = detectMinEigenFeatures(rgb2gray(I1), 'MinQuality', 0.05);

% Create the point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);

% Initialize the point tracker
imagePoints1 = imagePoints1.Location;
initialize(tracker, imagePoints1, I1);

% Track the points
[imagePoints2, validIdx] = step(tracker, I2);
matchedPoints1 = imagePoints1(validIdx, :);
matchedPoints2 = imagePoints2(validIdx, :);

[points1, points2] = ...
    vision.internal.inputValidation.checkAndConvertMatchedPoints(matchedPoints1, ...
    matchedPoints2, mfilename, 'matchedPoints1', 'matchedPoints2');

% Convert to double
points1 = cast(points1, 'double');
points2 = cast(points2, 'double');

% Estimate the essential matrix
[E, epipolarInliers] = estimateEssentialMatrix(...
    points1, points2, cameraParams, 'Confidence', 99.99);

% Find epipolar inliers
inlierPoints1 = points1(epipolarInliers, :);
inlierPoints2 = points2(epipolarInliers, :);

[orient, loc] = relativeCameraPose(E, cameraParams, inlierPoints1, inlierPoints2);

camMatrix1 = cameraMatrix(cameraParams, eye(3), [0 0 0]);

[R, t] = cameraPoseToExtrinsics(orient, loc); % MATLAB
camMatrix2 = cameraMatrix(cameraParams, R, t);

camMatrix1 = camMatrix1';
camMatrix2 = camMatrix2';

end