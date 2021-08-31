% Large Occlusion Stereo algorithm

% INPUT
%   I1 the left stereo image
%   I2 the right stereo image
%   min_d minimum disparity
%   max_d maximum disparity
%   method used for calculating the correlation scores
%   Valid values include: 'SAD', 'SSD', 'STAD', 'ZSAD', 'ZSSD', 'SSDNorm', 'NCC',
%   'AFF', 'LIN', 'BTSSD', 'BTSAD', 'TAD_C+G'
%   h, w heigth and width from the Fixed Windows, respectively 
%   reverse used to calc disparity map from left to rigth, input 1 or -1,
%   1 means regular disparity calculation, -1 means reverse disparity
%   calculation
%
%   I1, I2, min_d, max_d, method, h, w, and reverse must be provided by the user
%
%   disparityPenalty Penalty for disparity disagreement between pixels
%
% OUTPUT
%   D Disparity Image

%
% Example:
% [D, D2] = lo(I1,I2,0,15,'SAD',0,0,1,0.009);

%References
% Bobick, Aaron F., and Stephen S. Intille. "Large occlusion stereo." 
% International Journal of Computer Vision 33.3 (1999): 181-200.
%
% <http://mccormickml.com/assets/StereoVision/Stereo%20Vision%20-%20Mathworks%20Example%20Article.pdf>

% Prepared by: Gabriel da Silva Vieira, Brazil (May 2017)



function [D, D2] = lo(I1, I2, min_d, max_d, method, h, w, reverse, disparityPenalty)

% the range of disparity values from min_d to max_d inclusive
d_vals = min_d : max_d;
offsets = length(d_vals);

% Get the image dimensions.
[height, width, ~] = size(I1);

% Initialize the empty disparity map.
D = zeros(height, width, 'double');

% =============================================
%           Dynamic Programming
% =============================================

% False infinity
finf = realmax; % realmax is the largest finite floating-point number in IEEE® double precision

% Initialize a 'disparity space image - DSI' matrix.
% All values are initialized to a large value ('false infinity').
% The matrix has one row per image column, and one column for each possible 
% disparity value.
% This matrix is used for a single row of the image, and then re-initialized
% for the next row.
DSI = finf * ones(width, 2 * (offsets-1) + 1, 'double');

% Execute block_matching to construct the DSI matrix
[~, ~, C1] = block_matching(I1, I2, min_d, max_d, method, h, w, reverse);

[~, w_disp] = size(DSI);

% For each row of pixels in the image...
for row = 1:height
    
	% Re-initialize the disparity cost matrix.
    DSI(:) = finf;

    middle = round(w_disp/2); % column in the middle of the DSI
    
    % create a dsi structure from block_matching output function
    % it is the left side of the DSI matrix from the middle
    for i = 1:offsets        
        DSI(i:end,middle) = C1(row,i:end,i)';
        middle = middle-1;
    end
    
    %middle = round(w_disp/2);

    % create a dsi structure from block_matching output function
    % it is the rigth side of the DSI matrix from the middle
    %for i = 1:offsets-1 
     %   DSI(1:end-i,middle+1) = C2(row,i+1:end,i+1)';
      %  middle = middle+1;
    %end
       
    % Process scan line disparity costs with dynamic programming.
    
	% optimalIndeces will be a lookup table which will tell you what the 
	% disparity should be for the pixel in column k+1 given pixel k's 
	% disparity.
	optimalIndices = zeros(size(DSI));
    
	% Start with the DSI values for the rightmost pixel on the current
	% line of the image.
	cp = DSI(end, :);
	
	% For each pixel in the scan line from right to left...
	% (j is initialized to the second to last image column, then iterates
	% towards the leftmost column.)
    for j = width-1:-1:1
        
		% MW - "False infinity for this level"
		% (width - j + 1) = the number of pixels over we are from the right
		% edge of the image.
        cfinf = (width - j + 1) * finf;
		
        % Construct matrix for finding optimal move for each column
        % individually.
		% 
		% Find the minimum value in each column of this matrix.
		%     v - becomes a row vector containing the minimum values.
		%    ix - becomes a row vector containing the row index of the min for
		%         each column.
        [v,ix] = min([cfinf cfinf cp(1:end-4)+3*disparityPenalty;
                      cfinf cp(1:end-3)+2*disparityPenalty;
                      cp(1:end-2)+disparityPenalty;
                      cp(2:end-1);
                      cp(3:end)+disparityPenalty;
                      cp(4:end)+2*disparityPenalty cfinf;
                      cp(5:end)+3*disparityPenalty cfinf cfinf],[],1);
        
		% Select the DSI values for the next pixel to the left, and make the
		% following modifications:
		%   - Replace the leftmost and rightmost block DSI value with 'cfinf'
		%     (which grows linearly in magnitude as we move left).
		%   - Add the minimum values from the above matrix to all of the DSI
		%     values.
		cp = [cfinf DSI(j,2:end-1)+v cfinf];
        
		% Record optimal routes.
        optimalIndices(j, 2:end-1) = (2:size(DSI,2)-1) + (ix - 4);
    end
	
    % Recover optimal route.	
	% Get the minimum cost for the leftmost pixel and store it in D.
    [~,ix] = min(cp);
    D(row,1) = ix;
    
	% For each of the remaining pixels in this row...
	for k = 1:(width-1)
        % Set the next pixel's disparity.
		% Lookup the disparity for the next pixel by indexing into the 
		% 'optimalIndeces' table using the current pixel's disparity.
		D(row,k+1) = optimalIndices(k, ...
            max(1, min(size(optimalIndices,2), round(D(row,k)) ) ) );
    end
end

D = D - offsets;

D2 = D;

D = imcomplement(D);

end
