%
% Apply a median filter in the input images
%
% I1 - input image
% I2 - input image
%
% I1 and I2 must be provided by the user
%
% h - height of the filter
% w - width of the filter

function [out1, out2] = median_filter(I1, I2, h, w)

R = colfilt(I1(:,:,1),[h w],'sliding',@median);
G = colfilt(I1(:,:,2),[h w],'sliding',@median);
B = colfilt(I1(:,:,3),[h w],'sliding',@median);
out1 = cat(3, R, G, B);

R = colfilt(I2(:,:,1),[h w],'sliding',@median);
G = colfilt(I2(:,:,2),[h w],'sliding',@median);
B = colfilt(I2(:,:,3),[h w],'sliding',@median);
out2 = cat(3, R, G, B);

end