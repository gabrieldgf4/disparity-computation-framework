

% Absolute difference in x-direction

% matchedPoints1, matchedPoints2 -
%   Coordinates of matched points, specified as an M-by-2 matrix of M number of [x y] coordinates, 
% or as BRISKPoints, FASTPoints, HarrisPoints, SURFPoints, or MSERRegions object.
%
% I1 - reference image

function [D, I1] = abs_xdirection(matchedPoints1, matchedPoints2, I1)

rounded_points1 = round_points(matchedPoints1);
rounded_points2 = round_points(matchedPoints2);

D = prepare_map(rounded_points1, rounded_points2, I1);

end

function D = prepare_map(rounded_points1, rounded_points2, I)

    x_diff = abs(rounded_points1(:,1) - rounded_points2(:,1));

    [h, w, ~] = size(I);

    D = NaN(h, w);

    for i=1:length(x_diff)
        D( rounded_points1(i, 2), rounded_points1(i, 1) ) = x_diff(i);
    end

end


function rounded_points = round_points(matchedPoints)

    if isa( matchedPoints, 'BRISKPoints' )
        rounded_points = round( matchedPoints.Location );
    elseif isa( matchedPoints, 'cornerPoints' )
        rounded_points = round( matchedPoints.Location );
    elseif isa( matchedPoints, 'SURFPoints' )
        rounded_points = round( matchedPoints.Location );
    else
        rounded_points = round( matchedPoints );
    end

end