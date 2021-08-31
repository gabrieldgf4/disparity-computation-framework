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
 %   seg_method, mean_shift==1; superpixel==2
 %   moda_thresh - threshold [(moda-moda_thresh), moda, (moda+moda_tresh)]
 %   gammas = gamma_c - a constant of color similarity for bilateral filter
 %   gamma_p a constant of proximity similarity for bilateral filter
 %   dim_x window size in X for bilateral filter
 %   dim_y window size in Y for bilateral filter
 %   inpainting, if 1 then apply inpainting

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
 % it doens't apply texturelessRegions and inpainting, but uses
 % seg_method=mean-shift and metric=mean
 % D_out = scc_v2(D,I1,1,18,1,1,1,[23,14],39,39,0);
 %
 % with superpixel, metric=median and bilateral filter no spatial
 % D_out = scc_v2(D,I1,39,18,2,2,1,[23],39,39,0);
 % with mean-shift, metric=mean, and bilateral filter
 % D_out = scc_v2(D,I1,39,18,1,3,1,[23,14],39,39,0);
 %
 
 
 % Prepared by: Gabriel da Silva Vieira, Brazil (Jan 2018)

function [D_out, D_holes] = scc_v2(D, I, windowSize, thresh, seg_method, metric,...
    moda_thresh, gammas, dim_x, dim_y, inpainting)

% dim_x window size in X for bilateral filter
% dim_y window size in Y for bilateral filter
%dim_x = 39; dim_y = 39;

if seg_method==1
    % Mean-shift segmentation algorithm
    % hs - spatial bandwith for mean shift analysis
    % hr - range bandwidth for mean shift analysis
    % M  - minimum size of final output regions for mean shift
    hs = 7; hr = 7; M = 5; 
    [~, L_I1_2] = mex_shawn(I,hs,hr,M);
elseif seg_method==2
    % Superpixel segmentation
    % N specifies the number of superpixels you want to create
    N = 500;
    L_I1_2 = superpixels(I,N); 
end

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
    
     if metric == 1
         segment_mode = nanmean(d_segments_2(:));
     elseif metric == 2
        segment_mode = nanmedian(d_segments_2(:));
     elseif metric == 3
         segment_mode = mode(d_segments_2(:));
     elseif metric == 4
        meanValue = nanmean(d_segments_2(:));
        % Compute the Mean absolute deviation (MAD)
        absoluteDeviation = abs(d_segments_2 - meanValue);
        % Compute the median of the absolute differences
        segment_mode = nanmean(absoluteDeviation(:));
     end
     
    % put the mode to the segment
    d_segments((d_segments > segment_mode+moda_thresh | d_segments < segment_mode-moda_thresh) & ~isnan(d_segments)) = 1000;
    d_segments((d_segments <= segment_mode+moda_thresh & d_segments >= segment_mode-moda_thresh) & ~isnan(d_segments)) = round(segment_mode);
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
if size(gammas,2) == 1 && inpainting ~= 1
    D_out = weight_disp_bl_no_spatial_v2(I,D_out,gammas(1),dim_x,dim_y); 
elseif size(gammas,2) == 2 && inpainting ~= 1
    D_out = weight_disp_bl_v2(I,D_out,gamma(1),gammas(2),dim_x,dim_y); 
end

if inpainting == 1
    % PARAMETERS
    tol           = 1e-5;
    maxiter       = 50;
    dt            = 0.1;
    param.M       = 40; % number of steps of the inpainting procedure;
    param.N       = 2;  % number of steps of the anisotropic diffusion;
    param.eps     = 1e-10;
    
    mask = isnan(D_out);

    D_out(isnan(D_out)) = 0;
    D_out = inpainting_transport(D_out,mask,maxiter,tol,dt,param);
end

end
