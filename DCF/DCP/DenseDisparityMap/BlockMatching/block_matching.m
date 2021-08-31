% Block matching from image I1 to image I2,
% using integral images for computing the matching costs.

 % INPUT
 %   I1 the left stereo image
 %   I2 the right stereo image
 %   min_d minimum disparity
 %   max_d maximum disparity
 %   method used for calculating the correlation scores
 %   Valid values include: 'SAD', 'SSD', 'STAD', 'ZSAD', 'ZSSD', 'SSDNorm', 'NCC',
 %   'AFF', 'LIN', 'BTSSD', 'BTSAD', 'TAD_C+G'
 %   h, w heigth and width from the Fixed Windows, respectively 
 %   reverse used to calc disparity map from left to rigth, 1 or -1,
 %   1 means regular disparity calculation, -1 means reverse disparity
 %   calculation
 %
 %   I1, I2, min_d, max_d, method, h, w, reverse must be provided by the user
 %
 %
 % OUTPUT
 %   D disparity values
 %   C_min cost associated with the minimum disparity at pixel (i,j)
 %   C  the cost volume for differences between I1 and I2
 %
 
 % References: 
 % Gabriele Facciolo, Nicolas Limare, Enric Meinhardt. Integral Images for Block Matching, 2014
 % Asmaa Hosni, Michael Bleyer, Margrit Gelautz. Secrets of adaptive support 
 % weight techniques for local stereo matching, 2013
 
 % Example
 % [D, C_min, C] = block_matching(I1,I2,0,15,'SAD',1,1,1);
 % using STAD
 % [D, C_min, C] = block_matching(I1,I2,0,15,{'STAD', 20},1,1,1);
 
 % Prepared by: Gabriel da Silva Vieira, Brazil (Jan 2017)

function [D, C_min, C] = block_matching(I1, I2, min_d, max_d, method, h, w, reverse) 

% Prepared to use 'STAD'
if length(method) == 2 && isa(method, 'cell') 
    if strcmp(method{1},'STAD')
        truncated_value = method{2};
        method = method{1};
    end
elseif strcmp(method,'STAD') && ~isa(method, 'cell')
    truncated_value = 20; %default
end

I1 = double(I1) / 255;
I2 = double(I2) / 255;

% window size to aggerate the cost
%w_heigth = h*2+1;
%w_width = w*2+1;
w_heigth = h;
w_width = w;

[h, w, channels] = size(I1);

% the range of disparity values from min_d to max_d inclusive
d_vals = min_d : max_d;
offsets = length(d_vals);
C = ones(h,w,offsets); % the cost volume

% validate input arguments
[I1, I2] = valid_inputs(I1, I2, offsets, w_heigth, w_width, method, reverse);

% Precomputed images needed for the cost evaluation (μ, σ,...)
if strcmp(method,'ZSSD') || strcmp(method,'SSDNorm') || strcmp(method,'NCC')...
        || strcmp(method,'AFF') || strcmp(method,'LIN') || strcmp(method,'ZSAD')
    
    [meanI1, normI1, varI1] = pre_compute_data(I1, w_heigth, w_width, h, w, channels);
    [meanI2, ~, ~] = pre_compute_data(I2, w_heigth, w_width, h, w, channels);
    
end

% Prepare same constante values
if strcmp(method, 'STAD') 
    if isempty(truncated_value)
        error('A truncated value needs to be informed');
    end
    %truncated_value = input('!!!!!! >> Inform a value to be truncated: ');
    % p.e, threshold = 20, h=w=7, and compare with SAD with h=w=7 
elseif strcmp(method, 'ZSAD') % Zero-mean SAD
     I1 = I1 - meanI1;
     I2 = I2 - meanI2;
elseif strcmp(method, 'BTSSD') || strcmp(method, 'BTSAD')
    I1_neg = (I1 + (imtranslate(I1, [-1 0])))./2;
    I1_pos = (I1 + (imtranslate(I1, [1 0])))./2;
    [I1_max, I1_min] = max_min_3(I1_neg, I1_pos, I1);
elseif strcmp(method, 'TAD_C+G')
    thresColor = 7/255;     
    thresGrad = 2/255;      
    gamma = 0.11;           % (1- \alpha) 
    
    if channels > 1
        I1_ = sum(I1,channels) / channels; 
        I2_ = sum(I2,channels) / channels; 
    else
        I1_ = I1;
        I2_ = I2;
    end
        
    fx_l = gradient(I1_);
    fx_l = fx_l + 0.5; % To get a range of values between 0 to 1
        
    fx_r = gradient(I2_);
    fx_r = fx_r + 0.5; % To get a range of values between 0 to 1

end

% To use sum function in an appropriate way
if channels == 1
    dimension = 3;
else
    dimension = channels;
end

% the main loop
for off=1:offsets    
    d = d_vals(off);
    v_shift = imtranslate(I2, [(reverse)*double(d) 0]);
    
    % precompute pixel distances
    if strcmp(method, 'SAD') || strcmp(method, 'ZSAD')
        C(:,:,off) = sad_cost(I1, v_shift, dimension, w_heigth, w_width);
    elseif strcmp(method, 'SSD')
        C(:,:,off) = ssd_cost(I1, v_shift, dimension, w_heigth, w_width);
    elseif strcmp(method, 'STAD')
        C(:,:,off) = stad_cost(I1, v_shift, dimension, w_heigth, w_width, truncated_value);
    elseif strcmp(method, 'ZSSD')
        C(:,:,off) = zssd_cost(I1, v_shift, dimension, w_heigth, w_width, meanI1, meanI2);
    elseif strcmp(method, 'SSDNorm')
        C(:,:,off) = ssdNorm_cost(I1, v_shift, channels, w_heigth, w_width, normI1);
    elseif strcmp(method, 'NCC')       
        C(:,:,off) = ncc_cost(I1, v_shift, dimension, w_heigth, w_width, meanI1, varI1);
    elseif strcmp(method, 'AFF')       
        C(:,:,off) = aff_cost(I1, v_shift, dimension, w_heigth, w_width, meanI1, varI1);
    elseif strcmp(method,'LIN')
        C(:,:,off) = lin_cost(I1, v_shift, dimension, w_heigth, w_width, normI1);
    elseif strcmp(method, 'BTSSD')          
        C(:,:,off) = btssd_cost(I1, v_shift, dimension, w_heigth, w_width, I1_max, I1_min);
    elseif strcmp(method, 'BTSAD')           
        C(:,:,off) = btsad_cost(I1, v_shift, dimension, w_heigth, w_width, I1_max, I1_min);
    elseif strcmp(method, 'TAD_C+G')        
        C(:,:,off) = tadCG_cost(I1, v_shift, dimension, w_heigth, w_width,...
    thresColor, thresGrad, reverse, fx_l, fx_r,  gamma, d);
    end

end
    
    [C_min, D] = min(C, [], 3);        

end

% Function to determine max and min values between 3 matrices
%
function [I_max, I_min] = max_min_3(I1,I2,I3)

 [h, w, c] = size(I1);
 I_max = NaN(h,w,c);
 I_min = NaN(h,w,c);
     for k=1:c
         I_max(:,:,c) = max(max(I1(:,:,c),I2(:,:,c)),I3(:,:,c));
         I_min(:,:,c) = min(min(I1(:,:,c),I2(:,:,c)),I3(:,:,c));
     end
end


function [I1, I2] = valid_inputs(I1, I2, offsets, r1, r2, method, reverse)

[h1,w1] = size(I1);
[h2,w2] = size(I2);

% Check to see if both the left and right images have same number of rows
% and columns
if h1~=h2 || w1~=w2
    error('Both left and right images should have the same number of rows and columns');
end

if offsets < 1
    error('Offsets need to be iqual or greater than 1');
end

if r1<1 || r2<1
    error('r1 and r2 need to be iqual or greater than 1');
end

if isequal(reverse,-1)
    I = I1;
    I1 = I2;
    I2 = I;
end

end
