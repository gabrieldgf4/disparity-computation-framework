% Segmented based disparity from image I1 to image I2,
% using moving averages for computing the matching costs.

% INPUT
%   I1 the left stereo image
%   I2 the right stereo image
%   min_d minimum disparity
%   max_d maximum disparity
%   method used for calculating the correlation scores
%   Valid values include: 'SAD', 'SSD', 'STAD', 'ZSAD', 'ZSSD', 'SSDNorm', 'NCC',
%   'AFF', 'LIN', 'BTSSD', 'BTSAD', 'TAD_C+G'
%   h, w heigth and width from the Segment Window, respectively 
%   reverse used to calc disparity map from left to rigth, input 1 or -1,
%   1 means regular disparity calculation, -1 means reverse disparity
%   calculation
%
%   I1, I2, min_d, max_d, method, h, w, and reverse must be provided by the user
%
%   lambda a small weight to pixels outside the segment, in [1] is 0.01 to
%   tsukuba
%
% OUTPUT
%   D disparity values
%   D1 disparity from left to right
%   D2 disparity from right to left
%
 
% Example
% [D, D1, D2] = sb(I1,I2,0,15,'TAD_C+G',12,12,1,0.01);

% References: 
% [1] M. Gerrits and P. Bekaert, Local Stereo Matching with Segmentation-based Outlier Rejection
% Proc. Canadian Conf. on Computer and Robot Vision, 2006
%
% [2] D. Comaniciu and P. Meer, Mean shift: A robust approach toward feature space analysis
% IEEE Transactions on Pattern Analysis and Machine Intelligence, 24:603–619, 2002
%
% [3] EDISON code
%  http://www.caip.rutgers.edu/riul/research/code/EDISON/index.html
% [4] Shai's mex wrapper code
%  http://www.wisdom.weizmann.ac.il/~bagon/matlab.html

% Prepared by: Gabriel da Silva Vieira, Brazil (Sep 2017)


function [D, D1, D2] = sb(I1, I2, min_d, max_d, method, h, w, reverse, lambda)

%Using Block Matching Cost
    [~, ~, C1] = block_matching(I1, I2, min_d, max_d, method, 1, 1, reverse);
    [~, ~, C2] = block_matching(I1, I2, min_d, max_d, method, 1, 1, -reverse);

%Prepare image segmentation using an optimized mean-shift algorithm
[S_I1, ~] = mex_shawn(I1,7,7,30); % it is a C code by EDISON 
[S_I2, ~] = mex_shawn(I2,7,7,30);

% the range of disparity values from min_d to max_d inclusive
%[h2, w2] = size(I1);
d_vals = min_d : max_d;
offsets = length(d_vals);

% Segmented Moving Loop
for off=1:offsets    
    C1(:,:,off) = segmented_moving_avg(C1(:,:,off), S_I1, h, w, lambda);
    C2(:,:,off) = segmented_moving_avg(C2(:,:,off), S_I2, h, w, lambda);
end

[~, D1] = min(C1, [], 3);
[~, D2] = min(C2, [], 3);

% Disparity Map Combination

% displacement = (max_d - min_d) - 1;
% D3 = imtranslate(D2, [displacement 0]);
% D = min(D1,D3);
% 
% C = min(C_min1, C_min2);
% C_min = min(C,[],3);

[heigth, width, ~] = size(I1);
if reverse == 1
    Y = repmat((1:heigth)', [1 width]);
    X = repmat(1:width, [heigth 1]) - D1;
    X(X<1) = 1;
    indices = sub2ind([heigth,width],Y,X);
elseif reverse == -1
    Y = repmat((1:heigth)', [1 width]);
    X = repmat(1:width, [heigth 1]) + D1;
    X(X>width) = width;
    indices = sub2ind([heigth,width],Y,X);
end

D = min(D1,D2(indices));

end

% Segmented Moving Average Algorithm
%
 % INPUT
 %   C the Cost value
 %   I_segmented the segmented image
 %   h, w heigth and width from the Fixed Windows, respectively 
 %   lambda a small weight to pixels outside the segment
 %
 % OUTPUT
 %   A Aggregation of segmentation-based moving average filter
 %
function A = segmented_moving_avg(C, I_segmented, h, w, lambda)
% Convert to grayscale
if size(C,3) > 1, C = rgb2gray(C); end
if size(I_segmented,3) > 1, I_segmented = rgb2gray(I_segmented); end

% Convert to double
C = cast(C, 'double');
I_segmented = cast(I_segmented, 'double');

% window size to aggerate the cost
%w_heigth = h*2+1;
%w_width = w*2+1;
w_heigth = h;
w_width = w;

%prepare bordes to moving averages
p_h = (w_heigth-1)/2;
q_h = p_h+1;
p_w = (w_width-1)/2;
q_w = p_w+1;
% add border to the Cost
C = padarray(C, [w_heigth, w_width]);
% add border on segmented image and rename it to s
s = padarray(I_segmented, [w_heigth, w_width]);

% takes unique values in segmented image
vet_id_clusters = unique(s)';
% takes the quantity of elements in segmented image
length_vet_id_cluster = length(vet_id_clusters);

% put an unique interger id for each segment
for id=1:length_vet_id_cluster
    s(s==vet_id_clusters(id)) = id;
end

% prepare A_r
[I_pad_h, I_pad_w] = size(C);
A_r = zeros(I_pad_h, I_pad_w);

% prepare A_s
A_s = zeros(I_pad_h, I_pad_w);

% prepare A
A = zeros(I_pad_h, I_pad_w);

%Start loops
begin_h = q_h+1;
begin_w = q_w+1;
max_h = I_pad_h - w_heigth;
max_w = I_pad_w - w_width;
for i=begin_h:max_h
    T = zeros(1,length_vet_id_cluster);
    for j=begin_w:max_w
        
        T(s(i,j+p_w)) = T(s(i,j+p_w)) + C(i,j+p_w);
        T(s(i,j-q_w)) = T(s(i,j-q_w)) - C(i,j-q_w);
        A_r(i,j) = T(s(i,j));
        A_s(i,j) = A_s(i,j-1) + C(i,j+p_w) - C(i,j-q_w);
    end
end

for j=begin_w:max_w
    T = zeros(1,length_vet_id_cluster);
    t = 0;
    for i = begin_h:max_h
        
        T(s(i+p_h,j)) = T(s(i+p_h,j)) + A_r(i+p_h,j);
        T(s(i-q_h,j)) = T(s(i-q_h,j)) - A_r(i-q_h,j);
        t = t + A_s(i+p_h,j) - A_s(i-q_h,j);
        A(i,j) = (lambda * (t - T(s(i,j)))) + T(s(i,j));
    end
end

A = A/(w_heigth*w_width); % takes the avarage from agragated values
A = A((w_heigth+1):(I_pad_h-w_heigth),(w_width+1):(I_pad_w-w_width)); % cuts images's border 

end

% Regular Recursive Moving Average Computation

function A = moving_avg(I, h, w)

if size(I,3) > 1, I = rgb2gray(I); end
I = cast(I, 'double');

% window size to aggerate the cost
w_heigth = h*2+1;
w_width = w*2+1;

%prepare bordes to moving averages
p_h = (w_heigth-1)/2;
q_h = p_h+1;
p_w = (w_width-1)/2;
q_w = p_w+1;
I_pad = padarray(I, [w_heigth, w_width]);

% prepare A_s
[I_pad_h, I_pad_w] = size(I_pad);
A_s = zeros(I_pad_h, I_pad_w);

% prepare A
A = zeros(I_pad_h, I_pad_w);

%Start loops
begin_h = q_h+1;
begin_w = q_w+1;
max_h = I_pad_h - w_heigth;
max_w = I_pad_w - w_width;
for i=begin_h:max_h
    for j=begin_w:max_w
        A_s(i,j) = A_s(i,j-1) + I_pad(i,j+p_w) - I_pad(i,j-q_w);
    end
end

for j=begin_w:max_w
    for i = begin_h:max_h
        A(i,j) = A(i-1,j) + A_s(i+p_h,j) - A_s(i-q_h,j);
    end
end

A = A/(w_heigth*w_width);
A = A((w_heigth+1):(I_pad_h-w_heigth),(w_width+1):(I_pad_w-w_width));

end
