
% This is a simpler variant of the AFF cost (LIN)

function out1 = lin_cost(I1, v_shift, dimension, w_heigth, w_width, normI1)

    dist = I1.*v_shift;
    
    [h, w, channels] = size(I1);
    result = NaN(h,w,channels);

    for k=1:channels
        prod = (sum_patches(dist(:,:,k), w_heigth, w_width)) .^ 2;
        norm_v_shift = norm_rectangle(v_shift(:,:,k), w_heigth, w_width);

        den = (normI1(:,:,k).*norm_v_shift).^2;
        den(den==0) = 1; 

        f1 = (max(normI1(:,:,k),norm_v_shift)).^2;
        f2 = 1 - (prod./den);

        result(:,:,k) = f1.*f2;  % This is a simpler variant of the AFF cost         
    end

    out1 = sum(result,dimension) / channels;
        
end