% Util to crop the border in images

% Prepared by: Gabriel da Silva Vieira (Jan 2017)

function I_cropped = crop_border(I, h, w)

[h_I, w_I] = size(I);

I_cropped = I(h+1:h_I-h, w+1:w_I-w);

end