% Segmentation (by Mean Shif) Plus Mode Area Algorithm

 % INPUT
 %   D initial disparity map
 %   I the Reference Image
 %
 %   D and I must be provided by the user
 %
 %   hs - spatial bandwith for mean shift analysis
 %   hr - range bandwidth for mean shift analysis
 %   M  - minimum size of final output regions
 %
 % OUTPUT
 %   D_out disparity values
 %
 
 % Reference: 
 % D. Comaniciu and P. Meer, Mean shift: A robust approach toward feature space analysis
 % IEEE Transactions on Pattern Analysis and Machine Intelligence, 24:603–619, 2002
 %
 % [3] EDISON code
    %  http://www.caip.rutgers.edu/riul/research/code/EDISON/index.html
 % [4] Shai's mex wrapper code
    %  http://www.wisdom.weizmann.ac.il/~bagon/matlab.html
 
 % Example
 % D_out = segment_mode(D,I1,7,7,5);
 
 % Prepared by: Gabriel da Silva Vieira, Brazil (Nov 2017)

function D_out = segment_mode(D, I, hs, hr, M)

% Mean-shift segmentation algorithm
[~, L_I1_2] = mex_shawn(I,hs,hr,M);

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
