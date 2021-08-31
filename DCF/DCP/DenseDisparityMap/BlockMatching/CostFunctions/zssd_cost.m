
% Zero mean of Sum of Square Differences (ZSSD)

function out1 = zssd_cost(I1, v_shift, dimension, w_heigth, w_width, meanI1, meanI2)

    [~, ~, channels] = size(I1);

    dist = (I1 - v_shift).^2;
    dist = sum(dist,dimension)/channels;
    ssd = sum_patches(dist,w_heigth,w_width);
    
    meanI1 = ( meanI1(:,:,1) + meanI1(:,:,2) + meanI1(:,:,3) ) / 3;
    meanI2 = ( meanI2(:,:,1) + meanI2(:,:,2) + meanI2(:,:,3) ) / 3;
    
    out1 = ssd - (meanI1/3 - meanI2/3).^2;
        
end