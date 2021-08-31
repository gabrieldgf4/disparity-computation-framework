
% Compute the projective matrices between camera 1 and camera 2
%
% I1 - left image
% I2 - right image
% cameraParams - intrinsic parameter matrix from camera
%
% I1, I2, cameraParams must be provided by the user

function [out1, out2] = calibrated_rectify(I1, I2, cameraParams) 

I1gray = rgb2gray(I1);
I2gray = rgb2gray(I2);

% Find the Harris features.
points1 = detectHarrisFeatures(I1gray);
points2 = detectHarrisFeatures(I2gray);

% Extract the features.
[f1,vpts1] = extractFeatures(I1gray,points1);
[f2,vpts2] = extractFeatures(I2gray,points2);

% Retrieve the locations of matched points.
indexPairs = matchFeatures(f1,f2) ;
points1 = vpts1(indexPairs(:,1), :);
points2 = vpts2(indexPairs(:,2), :);

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

% call Fusiello Method
[out1, out2] = fusiello_rectify(I1, I2, camMatrix1', camMatrix2');

end