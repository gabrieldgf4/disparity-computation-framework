
% Birchfield and Tommasi Sampling Insensitive distance (BTSSD)

function out1 = btssd_cost(I1, v_shift, dimension, w_heigth, w_width, I1_max, I1_min)

    [h, w, channels] = size(I1);

    I2_neg = (v_shift + (imtranslate(v_shift, [-1 0])))./2;
    I2_pos = (v_shift + (imtranslate(v_shift, [1 0])))./2;
    [I2_max, I2_min] = max_min_3(I2_neg, I2_pos, v_shift);

    result = NaN(h,w,channels);
    for k=1:channels      
        d_LR = max_min_3(zeros(h,w), (I1(:,:,k) - I2_max(:,:,k)), (I2_min(:,:,k) - I1(:,:,k)));
        d_RL = max_min_3(zeros(h,w), (v_shift(:,:,k) - I1_max(:,:,k)), (I1_min(:,:,k) - v_shift(:,:,k)));      
        d_bt = (min(d_LR,d_RL)).^2; 
        result(:,:,k) = sum_patches(d_bt, w_heigth,w_width);
    end

    out1 = sum(result,dimension) / channels;
        
end

% Function to determine max and min values between 3 matrices
%
function [I_max, I_min] = max_min_3(I1,I2,I3)

 [h, w, c] = size(I1);
 I_max = NaN(h,w,c);
 I_min = NaN(h,w,c);
     for k=1:c
         I_max(:,:,c) = max(max(I1(:,:,c),I2(:,:,c)),I3(:,:,c));
         I_min(:,:,c) = min(min(I1(:,:,c),I2(:,:,c)),I3(:,:,c));
     end
end