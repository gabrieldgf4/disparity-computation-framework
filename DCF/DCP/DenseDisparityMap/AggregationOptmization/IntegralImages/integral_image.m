% Computing Integral Image
% Source: Gabriele Facciolo, Nicolas Limare, Enric Meinhardt. 
% Integral Images for Block Matching, 2014

% Prepared by: Gabriel da Silva Vieira (Jan 2017)

function ii = integral_image(I)

[h, w] = size(I);

ii = NaN(h, w);
ii(1,1) = I(1,1);

for x=2:h
    ii(x,1) = ii(x-1,1) + I(x,1);
end

for y=2:w
    s = I(1,y); % scalar accumulator
    ii(1,y) = ii(1,y-1) + s;
    for x=2:h
        s = s + I(x,y);
        ii(x,y) = ii(x, y-1) + s;
    end
end
end