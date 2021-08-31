% Segmentation (by Super Pixel) Plus Mode Area Algorithm

 % INPUT
 %   D initial disparity map
 %   I the Reference Image
 %
 %   D and I must be provided by the user
 %
 % 
 %   k - Number of desired superpixels. Note that this is nominal
 %       the actual number of superpixels generated will generally
 %       be a bit larger, espiecially if parameter m is small.
 %   m - Weighting factor between colour and spatial
 %       differences. Values from about 5 to 40 are useful.  Use a
 %       large value to enforce superpixels with more regular and
 %       smoother shapes. Try a value of 10 to start with.
 %   seRadius - Regions morphologically smaller than this are merged with
 %              adjacent regions. Try a value of 1 or 1.5.  Use 0 to
 %              disable.
 %   colopt - String 'mean' or 'median' indicating how the cluster
 %            colour centre should be computed. Defaults to 'mean'
 %   mw - Optional median filtering window size.  Image compression
 %        can result in noticeable artifacts in the a*b* components
 %        of the image.  Median filtering can reduce this. mw can be
 %        a single value in which case the same median filtering is
 %        applied to each L* a* and b* components.  Alternatively it
 %        can be a 2-vector where mw(1) specifies the median
 %        filtering window to be applied to L* and mw(2) is the
 %        median filtering window to be applied to a* and b*.
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
 % D_out = superpixel_mode(D,I1,2000,10,1,'mean',0);
 
 % Prepared by: Gabriel da Silva Vieira, Brazil (Nov 2017)

function D_out = superpixel_mode(D, I, k, m, seRadius, colopt, mw)

% Superpixel segmentation algorithm
[L_I1_2, Am, Sp, d] = slic(I,k, m, seRadius, colopt, mw);

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
