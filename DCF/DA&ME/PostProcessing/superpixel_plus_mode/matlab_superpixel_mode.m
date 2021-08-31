% Segmentation (by Super Pixel) Plus Mode Area Algorithm

 % INPUT
 %   I the Reference Image
 %   D initial disparity map
 %   N - Desired number of superpixels, specified as a numeric scalar
 %
 % OUTPUT
 %   D_out disparity values
 %
 
 % Reference: 
 % Radhakrishna Achanta, Appu Shaji, Kevin Smith, Aurelien Lucchi, 
 % Pascal Fua, and Sabine Susstrunk, SLIC Superpixels Compared to 
 % State-of-the-art Superpixel Methods. IEEE Transactions on Pattern 
 % Analysis and Machine Intelligence, Volume 34, Issue 11, pp. 2274-2282, 
 % May 2012
 
 % Example
 % D_out = matlab_superpixel_mode(I1,D,700);
 
 % Prepared by: Gabriel da Silva Vieira, Brazil (Nov 2017)

function D_out = matlab_superpixel_mode(I, D, N)

% Superpixel segmentation algorithm
[L_I1_2, NumLabels] = superpixels(I,N);

% For each segment we put the best disparity
D(isnan(D)) = 0;
D_out = zeros(size(I,1),size(I,2));
segments_id = unique(L_I1_2);
labels = double(L_I1_2);
d_segments = D;
for i=1:length(segments_id)
    % select a segment one by one
    labels(labels ~= segments_id(i)) = NaN;
    % remove those segments which are not considered
    d_segments(isnan(labels)) = NaN;
    % it avoids that the mode == 0;
        d_segments_2 = d_segments;
        d_segments_2(d_segments_2 == 0) = NaN;
        segment_mode = mode(d_segments_2(:));
    % put the mode to the segment
    d_segments(~isnan(d_segments)) = segment_mode;
    % prepare to make the composite, it is necessary because NaN + Int ==
    % NaN
    d_segments(isnan(d_segments)) = 0;
    % the segments composite
    D_out = D_out + d_segments;
    
    labels = double(L_I1_2);
    d_segments = D;
end

end
