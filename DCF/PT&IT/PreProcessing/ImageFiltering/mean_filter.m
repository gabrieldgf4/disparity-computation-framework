%
% Apply a mean filter in the input images
%
% I1 - input image
% I2 - input image
%
% I1 and I2 must be provided by the user
%
% h - height of the filter
% w - width of the filter

function [out1, out2] = mean_filter(I1, I2, h, w)

kernel = ones(h,w) / (h*w);

R = imfilter(I1(:,:,1), kernel);
G = imfilter(I1(:,:,2), kernel);
B = imfilter(I1(:,:,3), kernel);
out1 = cat(3, R, G, B);

R = imfilter(I2(:,:,1), kernel);
G = imfilter(I2(:,:,2), kernel);
B = imfilter(I2(:,:,3), kernel);
out2 = cat(3, R, G, B);

end
