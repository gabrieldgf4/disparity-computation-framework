
% According to D map the target image (I2) is shiffited to the reference image, 
% resulting a new image (I2new). Then, ssim metric compares I1 and I2new.
%
% D - Disparity map
% I1 - reference image
% I2 - target image 
% reverse - if 1 left to right, if -1 right to left.
%
% D, I1 and I2 must be provided by the user


function [D, ssim_error, I2new] = tar2ref_metric(D, I1, I2, reverse)

    D( isnan(D) ) = 0;
    D = double(D);

    [h, w, ~] = size(I1);

    if reverse == 1     % Left-right   
        Y = repmat((1:h)', [1 w]);
        X = repmat(1:w, [h 1]) - D;
        X(X<1) = 1;
        indices = sub2ind([h,w],Y,X);
    elseif reverse == -1 % Right-left
        Y = repmat((1:h)', [1 w]);
        X = repmat(1:w, [h 1]) + D;
        X(X>w) = w;
        indices = sub2ind([h,w],Y,X);
    end

    I2r = I2(:,:,1);
    I2g = I2(:,:,2);
    I2b = I2(:,:,3);

    I2new = cat(3, I2r(indices), I2g(indices), I2b(indices));

    ssim_error = 1 - ssim(I1, I2new);

end