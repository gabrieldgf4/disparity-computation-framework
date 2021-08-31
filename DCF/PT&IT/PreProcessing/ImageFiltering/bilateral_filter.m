%
% Apply bilateral filter in the input images
%
% I1 - input image
% I2 - input image
%
% I1 and I2 must be provided by the user
%
%  DegreeOfSmoothing - specifies the amount of smoothing
%  in the output image using DegreeOfSmoothing, a positive scalar. A small
%  value will smooth neighborhoods with small variance (uniform areas) and
%  neighborhoods with larger variance (such as edges) will not be smoothed.
%  Larger values will allow smoothing of higher variance neighborhoods,
%  such as stronger edges, in addition to the relatively uniform
%  neighborhoods. 
%  Default: 0.01*diff(getrangefromclass(A)).^2.
%
%  SpatialSigma - additionally
%  specifies the standard deviation of the spatial Gaussian smoothing
%  kernel. Larger values increase the contribution of further neighboring
%  pixels, effectively increasing the neighborhood size. 
%  Default: 1.


function [out1, out2] = bilateral_filter(I1, I2, degreeOfSmoothing, spatialSigma)

out1 = imbilatfilt(I1, degreeOfSmoothing, spatialSigma);

out2 = imbilatfilt(I2, degreeOfSmoothing, spatialSigma);

end
