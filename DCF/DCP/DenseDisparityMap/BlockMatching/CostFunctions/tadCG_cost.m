
% Truncated SAD of color images for current displacement (TAD_C+G)

function out1 = tadCG_cost(I1, v_shift, dimension, w_heigth, w_width,...
    thresColor, thresGrad, reverse, fx_l, fx_r,  gamma, d)

    [~, ~, channels] = size(I1);

    p_color = abs(I1 - v_shift); % Absolute Differences (AD)
    p_color = sum(p_color,dimension) / channels;
    p_color = min(p_color,thresColor);

    tmp = imtranslate(fx_r,[(reverse)*d 0]);
    p_grad = abs(tmp - fx_l);
    p_grad = min(p_grad,thresGrad);

    p = gamma*p_color + (1-gamma)*p_grad; % Combined color and gradient

    out1 = sum_patches(p,w_heigth,w_width);
        
end