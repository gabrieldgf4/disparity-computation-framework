
% Sum of Squared Differences (SSD)

function out1 = ssd_cost(I1, v_shift, dimension, w_heigth, w_width)

    [~, ~, channels] = size(I1);

    dist = (I1 - v_shift).^2; 
    dist = sum(dist,dimension)/channels;
    out1 = sum_patches(dist,w_heigth,w_width);
        
end