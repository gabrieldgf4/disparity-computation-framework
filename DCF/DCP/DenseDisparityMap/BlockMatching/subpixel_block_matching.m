% Subpixel stereo block matching using integral image

 % INPUT
 %   I1 the left stereo image
 %   I2 the right stereo image
 %   min_d minimum disparity
 %   max_d maximum disparity
 %   method used for calculating the correlation scores
 %   h, w heigth and width from the Fixed Windows, respectively 
 %   reverse used to calc disparity map from left to rigth, input 1 or -1,
 %   1 means regular disparity calculation, -1 means reverse disparity
 %   calculation
 %
 %   I1, I2, min_d, max_d and method must be provided by the user
 %
 %   s A subpixel precision s < 1, tipically 0.25 or 0.5
 %
 % OUTPUT
 %   D_min_subpixel disparity values
 %   C_min_subpixel cost associated with the minimum disparity at pixel (i,j)
 %

 % References: 
 % [1] Gabriele Facciolo, Nicolas Limare, Enric Meinhardt. 
 % Integral Images for Block Matching, 2014
 
 % Example
 % [D_min_subpixel, C_min_subpixel] = subpixel_block_matching(I1,I2,0,15,'SAD',1,1,1,1/16);

 % Prepared by: Gabriel da Silva Vieira, Brazil (Jan 2017)
 
function [D_min_subpixel, C_min_subpixel] = subpixel_block_matching(I1,...
    I2, min_d, max_d,  method, h, w, reverse, s)

if s >= 1
    error('s need to be less than 1');
end

% the range of disparity values from min_d to max_d inclusive
d_vals = min_d : max_d;
offsets = length(d_vals);

[h_I1, w_I1, ~] = size(I1);
vet_subpixel = 0:s:offsets;
length_vet = length(vet_subpixel);

C_subPixel = NaN(h_I1, w_I1, length_vet);

for shift=1:length_vet
    shifted_I2 = imtranslate(I2, [vet_subpixel(shift) 0]);
    [~, ~, C] = block_matching(I1, shifted_I2, 0, 0, method, h, w, reverse);
    C_subPixel(:,:,shift) = C;
end

[C_min_subpixel, D_min_subpixel] = min(C_subPixel, [], 3);

end
