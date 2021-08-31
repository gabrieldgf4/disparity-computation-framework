
% Normalized Cross Correlation

function out1 = ncc_cost(I1, v_shift, dimension, w_heigth, w_width, meanI1, varI1)

    [h, w, channels] = size(I1);

    dist = I1.*v_shift;
        
    prod = NaN(h,w,channels);
    mean_v_shift = NaN(h,w,channels);
    var_v_shift = NaN(h,w,channels);

    for k=1:channels
        prod(:,:,k) = (sum_patches(dist(:,:,k), w_heigth, w_width)) / (w_heigth * w_width);
        mean_v_shift(:,:,k) = mean_rectangle(v_shift(:,:,k), w_heigth, w_width);
        var_v_shift(:,:,k) = variance_rectangle(v_shift(:,:,k), w_heigth, w_width);
    end

    medias = meanI1 .* mean_v_shift;
    num = prod - medias;

    den = sqrt(varI1 .* var_v_shift);
    % prevent divisions by zero, Under that circumstance the cost should be set to 1
    %num(num==0) = 1; den(den==0) = 1;

    corr = num ./ den; % Normalized Cross Correlation (NCC)
    corr(isnan(corr)) = -1;

    result = sum(corr,dimension)/channels;

    out1 = 1 - result;
        
end