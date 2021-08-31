
% Sum of Absolute Differences (SAD)

function out1 = sad_cost(I1, v_shift, dimension, w_heigth, w_width)

    [~, ~, channels] = size(I1);

    dist = abs(I1 - v_shift); 
    dist = sum(dist,dimension)/channels;
    out1 = sum_patches(dist,w_heigth,w_width);
        
end