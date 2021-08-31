% segment consistency check (SCC)
% Segmentation (by Mean Shif) Plus Mode Area Algorithm

 % INPUT
 %   D initial disparity map
 %   I the Reference Image
 %
 %   D and I must be provided by the user
 %
 %   windowSize - size of the mask to be used in the textureless algorithm
 %   thresh - to be applied in the textureless algorithm
 %   hs - spatial bandwith for mean shift analysis
 %   hr - range bandwidth for mean shift analysis
 %   M  - minimum size of final output regions for mean shift
 %   moda_thresh - threshold [(moda-moda_thresh), moda, (moda+moda_tresh)]
 %   gammas = gamma_c - a constant of color similarity for bilateral filter
 %   gamma_p a constant of proximity similarity for bilateral filter
 %   dim_x window size in X for bilateral filter
 %   dim_y window size in Y for bilateral filter
 %
 % OUTPUT
 %   D_out disparity values
 %
 
 % Reference: 
 %
 % Vieira, Gabriel, et al. "A Segmented Consistency Check Approach to Disparity Map Refinement." 
 % Canadian Journal of Electrical and Computer Engineering 41.4 (2018): 218-223.
 %
 % D. Comaniciu and P. Meer, Mean shift: A robust approach toward feature space analysis
 % IEEE Transactions on Pattern Analysis and Machine Intelligence, 24:603–619, 2002
 %
 % [3] EDISON code
    %  http://www.caip.rutgers.edu/riul/research/code/EDISON/index.html
 % [4] Shai's mex wrapper code
    %  http://www.wisdom.weizmann.ac.il/~bagon/matlab.html
 
 % Example
 % with bilateral filter no spatial
 % D_out = scc(D,I1,39,18,7,7,5,1,[23],39,39);
 % with bilateral filter
 % D_out = scc(D,I1,39,18,7,7,5,1,[23,14],39,39);
 %
 % it doens't apply texturelessRegions and final filtering
 % D_out = scc(D,I1,1,1,7,7,5,1,23,39,39);
 
 % Prepared by: Gabriel da Silva Vieira, Brazil (Jan 2018)

function [D_out, D_holes] = scc(D, I, windowSize, thresh, hs, hr, M,...
    moda_thresh, gammas, dim_x, dim_y)

% Mean-shift segmentation algorithm
[~, L_I1_2] = mex_shawn(I,hs,hr,M);

if windowSize ~= 1
    % Find textureless regions
    [texturelessImg] = findTexturelessRegions(I, windowSize, thresh);
    % label the textureless area
    texturelessImg = bwlabel(texturelessImg);

    % it consideres textureless regions
    textura_id = unique(texturelessImg)+1;
    labels = double(L_I1_2);
    textura = texturelessImg;
    for i=1:length(textura_id)-1
        % select a texture one by one
        textura(textura ~= textura_id(i)) = NaN;

        % area of the texture
        area_tex = ~isnan(textura);
        area_tex = sum(sum(area_tex));

        % select segments in labels
        [l,c] = find(~isnan(textura),1);
        rotulo = labels(l,c);
        labels(labels ~= rotulo) = NaN; 

        % area of the segment
        area_seg = ~isnan(labels);
        area_seg = sum(sum(area_seg));

        if area_tex > area_seg
            L_I1_2(~isnan(textura)) = rotulo;
        end

        labels = double(L_I1_2);
        textura = texturelessImg;
    end
end

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
    
    d_segments((d_segments > segment_mode+moda_thresh | d_segments < segment_mode-moda_thresh) & ~isnan(d_segments)) = 1000;
    d_segments((d_segments <= segment_mode+moda_thresh & d_segments >= segment_mode-moda_thresh) & ~isnan(d_segments)) = segment_mode;
    % prepare to make the composite, it is necessary because NaN + Int == NaN
    d_segments(isnan(d_segments)) = 0;
    % the segments composite
    D_out = D_out + d_segments;
    
    labels = double(L_I1_2);
    d_segments = D;
end

D_out(D_out >= 1000) = NaN;
D_out(D_out == 0) = NaN;

D_holes = D_out;

% Fill in holes;
if size(gammas,2) == 1
    D_out = weight_disp_bl_no_spatial_v2(I,D_out,gammas(1),dim_x,dim_y); 
elseif size(gammas,2) == 2
    D_out = weight_disp_bl_v2(I,D_out,gamma(1),gammas(2),dim_x,dim_y); 
end

end
