
%Example
% D2 = weight_disp_bl(I1,D_out,23,14,39,39); toc

function D = weight_disp_bl_v2(I, D, gamma_c, gamma_p, dim_x, dim_y)

I = double(I);

%%%% Spatial proximity of a neighboring pixel %%%%
area_win = dim_x*dim_y;
vector_points = NaN(area_win,2);
lin = dim_x;
cont = 1;
for i=1:dim_x:area_win
    vector_points(i:lin,1) = cont;
    vector_points(i:lin,2) = 1:dim_x;
    lin = lin+dim_x;
    cont = cont+1;
end
% Euclidean Distance
point_in_center = round(length(vector_points)/2);
dist = sqrt((vector_points(point_in_center, 1) - vector_points(:,1)).^2 + ...
    (vector_points(point_in_center, 2) - vector_points(:,2)).^2);

dist = reshape(dist',dim_x,dim_y); 
%%%%

%%%% the perceptual proximity strength
proximity = (dist./gamma_p);
%%%%

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
        W_I = exp(-(color_group_I + proximity));
        
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