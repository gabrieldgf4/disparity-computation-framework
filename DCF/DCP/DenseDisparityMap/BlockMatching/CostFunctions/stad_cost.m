
% Sum of truncated Absolute Differences (STAD)

function out1 = stad_cost(I1, v_shift, dimension, w_heigth, w_width, truncated_value)

    [~, ~, channels] = size(I1);

    dist = abs(I1 - v_shift); % Sum of Absolute Differences (SAD)
    dist = sum(dist,dimension)/channels;
    dist(dist > truncated_value) = truncated_value; % Sum of truncated absolute differences (STAD)
    out1 = sum_patches(dist,w_heigth,w_width);
        
end