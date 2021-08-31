%
% Apply bilateral filter in the input images
%
% I1 - input image
% I2 - input image
%
% I1 and I2 must be provided by the user
%
% It filters input image A under self-guidance i.e.,
% using A itself as the guidance image. This can be used for
% edge-preserving smoothing of image A.
%
%   'NeighborhoodSize' -  Scalar (Q) or two-element vector, [M N], of 
%                         positive integers that specifies the size of the
%                         rectangular neighborhood around each pixel used
%                         in guided filtering. If a scalar Q is specified,
%                         then the square neighborhood of size [Q Q] is
%                         used. Specified value cannot be greater than the
%                         size of the image. 
%                         Default value is [5 5].
%


function [out1, out2] = guided_filter(I1, I2, h, w)

out1 = imguidedfilter(I1, 'NeighborhoodSize', [h, w] );

out2 = imguidedfilter(I2, 'NeighborhoodSize', [h, w] );

end
