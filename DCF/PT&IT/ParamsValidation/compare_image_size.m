
function compare_image_size(I1, I2)

[h1, w1, c1] = size(I1);
[h2, w2, c2] = size(I2);

    if (h1 ~= h2) || (w1 ~= w2) || (c1 ~= c2)
        error( 'Error. Images must have the same size');
    end
    
end
