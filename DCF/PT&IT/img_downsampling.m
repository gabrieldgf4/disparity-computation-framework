
% Height and width of input image are adjusted to be multiple numbers of 
% scale parameter

function [Idown, Inew] = img_downsampling(I, scale)

    [h1, w1, ~] = size(I);

    h_border = 0;
    w_border = 0;
    while mod(h1, scale) ~= 0
        h1 = h1 + 1;
        h_border = h_border + 1;
    end
    while mod(w1, scale) ~= 0
        w1 = w1 + 1;
        w_border = w_border + 1;
    end

    if h_border ~= 0 || w_border ~= 0
        Idown = imresize(I, [h1/scale, w1/scale], 'nearest', 'Antialiasing', false);
        Inew = padarray(I, [h_border, w_border], 'post');
    else
        Idown = imresize(I, [h1/scale, w1/scale], 'nearest', 'Antialiasing', false);
        Inew = I;
    end

end