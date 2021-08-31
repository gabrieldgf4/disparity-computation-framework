% Variable Windows method from image I1 to image I2,
% using integral images for computing the matching costs.

% INPUT
%   I1 the left stereo image
%   I2 the right stereo image
%   min_d minimum disparity
%   max_d maximum disparity
%   method used for calculating the correlation scores
%   Valid values include: 'SAD', 'SSD', 'STAD', 'ZSAD', 'ZSSD', 'SSDNorm', 'NCC',
%   'AFF', 'LIN', 'BTSSD', 'BTSAD', 'TAD_C+G'
%   h_block, w_block heigth and width from the Fixed Windows, respectively 
%   reverse used to calc disparity map from left to rigth, input 1 or -1,
%   1 means regular disparity calculation, -1 means reverse disparity
%   calculation
%
%   I1, I2, min_d, max_d, method, h, w, and reverse must be provided by the user
%
%   h_min, h_max - minimum and maximum for a windows, in [1] h_min = 1
%   h_max = 15
%   alpha, beta, gamma - are parameters assigning relative weights to
%   terms in equation, in [1] alpha = 1.5, beta = 7, gamma = -2
%
% OUTPUT
%   D disparity values
%   C_min cost associated with the minimum disparity at pixel (i,j)
%   Cost_d  the cost volume for differences between I1 and I2
%

% Example
% [D, C_min, C] = vw(I1,I2,0,15,'BTSAD',1,1,1,4,31,1.5,7,-2);

% References: 
% [1] O. Veksler, Fast variable window for stereo correspondence using integral images
% In Proc. Conf. on Computer Vision and Pattern Recognition (CVPR 2003), pages 556–561, 2003
%
% [2] Tombari Federico; Mattoccia Stefano; Stefano Luigi Di, Classification and evaluation of 
% cost aggregation methods for stereo correspondence, IEEE, 2008.
%
% [3] Gabriele Facciolo, Nicolas Limare, Enric Meinhardt. Integral Images
% for Block Matching, 2014.

% Prepared by: Gabriel da Silva Vieira, Brazil (Jan 2017)
 
function [D, C_min, C] = vw(I1, I2, min_d, max_d, ...
    method, h_block, w_block, reverse, h_min, h_max, alpha, beta, gamma)
 
% Part 1
% For the leftmost and rigth most pixel of each line we will compute the best window 
% searching through the whole range between the smallest and largest window sizes. 
[Cost_1, vet_min_idx_lr, vet_min_idx_rl] = part1(I1, I2, min_d, max_d, ...
    method,h_block, w_block, h_min, h_max, alpha, beta, gamma, reverse);

% Part 2
% Considering Part 1, for the rest of pixels on that line we use previous 
% window size to limit the search range.
[Cost_2, Mx_out, My_out, Used_Windows] = part2(Cost_1, vet_min_idx_lr, ...
    vet_min_idx_rl, h_min, h_max, alpha, beta, gamma);

% Part 3
% Dynamic programming - use window cost as an estimate not just for the 
% pixel in the center of the window, but for all pixels in the window
C = dp2(Cost_2, Mx_out, My_out, Used_Windows);

% The minimum cost
[C_min, D] = min(C,[],3);


end
