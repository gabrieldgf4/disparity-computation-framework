% Function to compute mean and variance of value of a patch in a horizontal
% sense
function [mean_I, var_I] = mean_variance_horizontal(I, r)

    [h, w] = size(I);
    patch = NaN(1,w);   
    patch_elev = NaN(1,w);
    I_pad = padarray(I,[0 r-1],'post');
    ii = integral_image(I_pad);
    I_pad_elev = padarray(I.^2,[0 r-1],'post');
    ii_elev = integral_image(I_pad_elev); 
    for i=1:w
        patch(i) = sum_rectangle(ii,1,i,r,r);
        patch_elev(i) = sum_rectangle(ii_elev,1,i,r,r);
    end
    mean_I = patch./(r*r);
    mean_I_elev = patch_elev./(r*r);
    var_I = mean_I_elev - (mean_I).^2;
end