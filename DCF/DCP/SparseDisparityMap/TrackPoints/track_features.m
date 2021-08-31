
% Extract interest point descriptors
%
% I - input image, binary image | M-by-N 2-D grayscale image
%
% regionsObj - Center location point of a square neighborhood, specified as 
% either a BRISKPoints, SURFPoints, KAZEPoints, MSERRegions, cornerPoints , 
% or ORBPoints object, or an M-by-2 matrix of M number of [x y] coordinates.
%
% Method:
%   'Auto' (default) | 'BRISK' | 'FREAK' | 'SURF' | 'ORB' | 'KAZE' | 'Block'

% example:
% regionsObj = detectBRISKFeatures(I);
% track_features(I, regionsObj, 'auto');

function [features, validPoints] = track_features(I, regionsObj, method)

[features, validPoints] = extractFeatures(I, regionsObj, 'Method', method);

end