% Function to compute mean and variance of value of a patch in a horizontal
% sense
function [mean_I, var_I] = mean_variance_vertical(I, r)

    [h, w] = size(I);
    patch = NaN(h,1);   
    patch_elev = NaN(h,1);
    I_pad = padarray(I,[r-1 r-1],'post');
    ii = integral_image(I_pad);
    I_pad_elev = padarray(I.^2,[r-1 r-1],'post');
    ii_elev = integral_image(I_pad_elev); 
    for i=1:h
        patch(i) = sum_rectangle(ii,i,1,r,r);
        patch_elev(i) = sum_rectangle(ii_elev,i,1,r,r);
    end
    mean_I = patch./(r*r);
    mean_I_elev = patch_elev./(r*r);
    var_I = mean_I_elev - (mean_I).^2;
end