
% Sum of Square Differences Normalized (SSDNorm)

function out1 = ssdNorm_cost(I1, v_shift, dimension, w_heigth, w_width, normI1)

    [h, w, channels] = size(I1);

    dist = I1.*v_shift;
        
    prod = NaN(h,w,channels);
    norm_v_shift = NaN(h,w,channels);

    for k=1:channels
        prod(:,:,k) = sum_patches(dist(:,:,k), w_heigth, w_width);
        norm_v_shift(:,:,k) = norm_rectangle(v_shift(:,:,k), w_heigth, w_width);
    end

    den = normI1.*norm_v_shift;
    % prevent divisions by zero, Under that circumstance the cost should be set to 2
    den(den==0) = 1; prod(den==0) = 0; 
    result = 2 - (2.*(prod./den));
    out1 = sum(result,dimension)/channels; % SSD/Norm
        
end