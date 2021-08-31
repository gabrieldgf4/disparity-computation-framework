
%Example
% D2 = weight_disp_bl(I1,D_out,23,39,39); toc

function D = weight_disp_bl_no_spatial_v2(I, D, gamma_c, dim_x, dim_y)

I = double(I);

% Prepare bordes 
p_h = (dim_x-1)/2;
p_w = (dim_y-1)/2;

% To avoid ilegal indexes
I = padarray(I, [p_h p_w], 1000);
D = padarray(D, [p_h p_w], NaN);

% I1 dimensions
[height, width, channels] = size(I);
% To use sum function in an appropriate way
if channels == 1
    dimension = 3;
else
    dimension = channels;
end

%%%% For each D(i,j)==NaN, analise the similary between points
for i=p_h+1:height-p_h
    for j=p_w+1:width-p_w
        
        if isnan(D(i,j))
        
        center_point_I = I(i, j, :);

        win_I = I(i-p_h:i+p_h, j-p_w:j+p_w, :);
        win_D = D(i-p_h:i+p_h, j-p_w:j+p_w);
      
        % color similarity 
        diff_from_center_p_I = (bsxfun(@minus, center_point_I, win_I)).^2;
        diff_from_center_p_I = sum(diff_from_center_p_I, dimension) / channels;
        diff_from_center_p_I = sqrt(diff_from_center_p_I);
        
         % color similarity grouping
        color_group_I = (diff_from_center_p_I./gamma_c);
        
        % Equation (9), support weight window
        W_I = exp(-(color_group_I));
        
        W_I(isnan(win_D)) = NaN;
        
        disps = unique(win_D);
        disps(isnan(disps)) = [];        
        weight_disps = zeros(1,size(disps,1));
        for k=1:size(disps,1)
            logical_d = (win_D == disps(k));
            count_d = sum(sum(logical_d));
            sum_d = nansum(nansum((W_I(logical_d==1))));
            norm_d = sum_d; %/ count_d;
            weight_disps(k) = norm_d;
        end
        
        [~, index] = max(weight_disps);
        D(i,j) = disps(index);
        %[~, idx] = max(W_I(:));
        %[lin, col] = ind2sub(size(W_I), idx);
        
        %D(i,j) = win_D(lin,col);      

        end
    end
end

D = D(p_h+1:height-p_h, p_w+1:width-p_w, :);

end