%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 2
% Considering Part 1, for the rest of pixels on that line we use previous 
% window size to limit the search range.
%

function [Cost_d, Mx_out, My_out, Used_Windows] = part2(Cost, vet_min_idx_lr,...
    vet_min_idx_rl, h_min, h_max, alpha, beta, gamma)

[heigth, width, channel] = size(Cost);

Cost_d = NaN(heigth,width,channel);
Used_Windows = NaN(heigth,width,channel);

Mx_out = NaN(heigth,width,channel);
My_out = NaN(heigth,width,channel);


for disp=1:channel
    C_disp = Cost(:,:,disp);
    max_lr = max(vet_min_idx_lr(:,:,disp));
    max_rl = max(vet_min_idx_rl(:,:,disp));
    max_window = max(max_lr, max_rl);
    C_disp = padarray(C_disp, [max_window, 0], 'post'); % to avoid invalid indexes
    for i=1:heigth
        
        w_line_lr = vet_min_idx_lr(i);
        w_line_rl = vet_min_idx_rl(i);
        
        best_windows = [w_line_lr-1, w_line_lr, w_line_lr+1, w_line_rl-1, w_line_rl, w_line_rl+1];
        
        % using logical index to avoid windows smaller and bigger than
        % it is spected
        logical_min = best_windows >= h_min;
        best_windows = best_windows(logical_min);
        logical_max = best_windows <= h_max;
        best_windows = best_windows(logical_max);
        
        best_windows = unique(best_windows);
        
        C_W_marcador = realmax*ones(1, width); % realmax is the largest finite floating-point number in IEEE® double precision
        Mx = NaN(1, width);
        My = NaN(1, width);
        
        used_windows_marcador = zeros(1, width);

        for j=1:length(best_windows)
            
            w = best_windows(j);
            k = w+i-1; % k = x'-x +1
        
            [Cost_mean, Cost_variance] = mean_variance_horizontal(C_disp(i:k,:),w);
            C_W = veskler_cost(Cost_mean, Cost_variance, w, alpha, beta, gamma);
            
             % using logical indexes to verify what is the best cost and
             % what is the best windows to use for each pixel
            v_logico = C_W < C_W_marcador;
            [row, col] = find(v_logico);
            Mx(v_logico) = k;
            My(v_logico) = w+col-1;
            C_W_marcador(v_logico) = C_W(v_logico);
            used_windows_marcador(v_logico) = w;
            
        end
        
        Mx_out(i,:,disp) = Mx;
        My_out(i,:,disp) = My;       
        Cost_d(i,:,disp) = C_W_marcador;
        Used_Windows(i,:,disp) = used_windows_marcador;
        
    end
end
end