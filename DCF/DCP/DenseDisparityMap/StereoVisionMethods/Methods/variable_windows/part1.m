
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 1
% For the leftmost and rigth most pixel of each line we will compute the best window 
% searching through the whole range between the smallest and largest window sizes. 
%

function [Cost, vet_min_idx_lr, vet_min_idx_rl] = part1(I1, I2, min_d, max_d, ...
    method, h_block, w_block, h_min, h_max, alpha, beta, gamma, reverse)


% Execute block_matching to construct the DSI matrix
[~, ~, Cost] = block_matching(I1, I2, min_d, max_d, method, h_block, w_block, reverse);

[heigth, width, channel] = size(Cost);
h_vals = h_min:h_max;
length_h_vals = length(h_vals);

vet_lr = NaN(heigth,h_max,channel);
vet_rl = NaN(heigth,h_max,channel);

vet_min_idx_lr = NaN(heigth,1,channel);
vet_min_idx_rl = NaN(heigth,1,channel);

%%% an adaptation to work fine
[he,wi,co] = size(I1);
Cost = (Cost*co)*255;
%%%

for disp=1:channel
    C_disp = Cost(:,:,disp);
    %C_disp_flip = fliplr(C_disp);
    for i=1:length_h_vals
        w = h_vals(i);

        [Cost_mean, Cost_variance] = mean_variance_vertical(C_disp(:,1:w),w);
        %C_W = Cost_mean + (alpha.*(Cost_variance)) + (beta./(sqrt(w*w) + gamma));
        C_W = veskler_cost(Cost_mean, Cost_variance, w, alpha, beta, gamma);
        vet_lr(:,w,disp) = C_W;
            
        [Cost_mean, Cost_variance] = mean_variance_vertical(C_disp(:,end),w);
        %C_W = Cost_mean + (alpha.*(Cost_variance)) + (beta./(sqrt(w*w) + gamma));
        C_W = veskler_cost(Cost_mean, Cost_variance, w, alpha, beta, gamma);
        vet_rl(:,w,disp) = C_W;
    end
   
    [min_vet_lr, idx_min_vet_lr] = min(vet_lr(:,:,disp),[],2);  
    vet_min_idx_lr(:,:,disp) = idx_min_vet_lr;
    
    [min_vet_rl, idx_min_vet_rl] = min(vet_rl(:,:,disp),[],2);
    vet_min_idx_rl(:,:,disp) = idx_min_vet_rl;

end
end
