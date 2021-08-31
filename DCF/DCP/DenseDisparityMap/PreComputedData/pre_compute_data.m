
function [meanI, normI, varI] = pre_compute_data(I, w_heigth, w_width, h, w, channels)

meanI = NaN(h,w,channels);
normI = NaN(h,w,channels);
varI = NaN(h,w,channels);

    for k=1:channels
        [mI1, nI1, vI1] = stuff(I(:,:,k), w_heigth, w_width);
        meanI(:,:,k) = mI1;
        normI(:,:,k) = nI1;
        varI(:,:,k) = vI1;
    end

end