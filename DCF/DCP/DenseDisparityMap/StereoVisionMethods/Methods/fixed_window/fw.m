% Fixed window method (FW)

 %
 %   I1, I2, min_d, max_d, h, w and reverse must be provided by the user
 %

% Example
% [D, C_min, C] = fw(I1,I2,0,15,'SSD',1,1,1);

% Prepared by: Gabriel da Silva Vieira, Brazil (Jan 2017)

function [D, C_min, C] = fw(I1, I2, min_d, max_d, method, h, w, reverse)

% Execute block_matching to construct the DSI matrix
[D, C_min, C] = block_matching(I1 ,I2 ,min_d ,max_d, method, h, w,  reverse);

end
