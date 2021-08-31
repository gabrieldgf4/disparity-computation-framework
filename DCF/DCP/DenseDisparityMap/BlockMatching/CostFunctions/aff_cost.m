
% "affine" similarity measure (AFF)

function out1 = aff_cost(I1, v_shift, dimension, w_heigth, w_width, meanI1, varI1)

    dist = I1.*v_shift;
    
    [h, w, channels] = size(I1);
    result = NaN(h,w,channels);
    
    if w_heigth==1 && w_width==1
        out1 = sum(dist,dimension) / channels;
    else    
        for k=1:channels
            prod = (sum_patches(dist(:,:,k), w_heigth, w_width)) / (w_heigth * w_width);
            mean_v_shift = mean_rectangle(v_shift(:,:,k), w_heigth, w_width);
            var_v_shift = variance_rectangle(v_shift(:,:,k), w_heigth, w_width);

            medias = meanI1(:,:,k) .* mean_v_shift;
            num = prod - medias;
            den = sqrt(varI1(:,:,k) .* var_v_shift);
            den(den==0) = 1;

            corr = num ./ den;

            result(:,:,k) = max(varI1(:,:,k),var_v_shift).*min(1,1-(corr.*abs(corr))); % "affine" similarity measure 

        end
        
        out1 = sum(result,dimension) / channels;
    end
        
end