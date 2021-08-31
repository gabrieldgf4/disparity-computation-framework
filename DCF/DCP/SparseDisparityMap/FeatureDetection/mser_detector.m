
% Detect MSER features
%
% References
% [1] Nister, D., and H. Stewenius, "Linear Time Maximally Stable Extremal Regions", 
% Lecture Notes in Computer Science. 10th European Conference on Computer Vision, 
% Marseille, France: 2008, no. 5303, pp. 183–196.
%
% [2] Matas, J., O. Chum, M. Urba, and T. Pajdla. "Robust wide baseline stereo 
% from maximally stable extremal regions." Proceedings of British Machine Vision 
% Conference, pages 384-396, 2002.
%
% [3] Obdrzalek D., S. Basovnik, L. Mach, and A. Mikulik. "Detecting Scene 
% Elements Using Maximally Stable Colour Regions," Communications in Computer 
% and Information Science, La Ferte-Bernard, France; 2009, vol. 82 CCIS (2010 12 01), pp 107–115.
%
% [4] Mikolajczyk, K., T. Tuytelaars, C. Schmid, A. Zisserman, T. Kadir, and L. Van Gool, 
%"A Comparison of Affine Region Detectors"; International Journal of Computer Vision, 
%Volume 65, Numbers 1–2 / November, 2005, pp 43–72 .

function [matchedPoints1, matchedPoints2] = mser_detector(I1, I2)

if size(I1, 3) == 3
    I1 = rgb2gray(I1);
end

if size(I2, 3) == 3
    I2 = rgb2gray(I2);
end

regionsObj1 = detectMSERFeatures(I1);
[f1, vpts1] = extractFeatures(I1, regionsObj1);

regionsObj2 = detectMSERFeatures(I2);
[f2, vpts2] = extractFeatures(I2, regionsObj2);

% Retrieve the locations of matched points.
indexPairs = matchFeatures(f1,f2) ;
matchedPoints1 = vpts1(indexPairs(:,1), :);
matchedPoints2 = vpts2(indexPairs(:,2), :);

%showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2,'montage');
%title('Original images and matching feature points');

end