% Summing the pixel values in a rectangle of an image using the Integral Image.
% In: ii- integral image, x-y - position of corner left up from ii to draw a rectangle, 
% In: width (w) and height (h) of a rectangle contained in the image
% out: Sum of the pixel values of i in the rectangle of size w × h : s

% Reference: Gabriele Facciolo, Nicolas Limare, Enric Meinhardt. 
% Integral Images for Block Matching, 2014

% Prepared by: Gabriel da Silva Vieira (Jan 2017)

function s = sum_rectangle(ii, x, y, w, h)

s = ii(x + w-1, y + h-1);
if x > 1
    s = s - ii(x-1, y-1+h);
end
if y > 1
    s = s - ii(x-1+w, y-1);
end
if x > 1 && y > 1
    s = s + ii(x-1, y-1);
end
if s < 0
    s = 0;

end


