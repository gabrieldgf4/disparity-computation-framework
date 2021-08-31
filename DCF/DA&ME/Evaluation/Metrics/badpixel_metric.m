
% Bad pixel percentual
%
% D - Disparity map
% GT - ground truth map
% threshold - 
%
% D, GT and threshold must be provided by the user

function [D, result] = badpixel_metric(D, GT, threshold)

D = double(D);
GT = double(GT);

    qtty_disp_in_D = sum( sum( ~isnan(D) ) );
    
    D( isnan(D) ) = 0;
    GT( isnan(D) ) = 0;
    
    [h, w] = size(D);
    bad = zeros(h,w); 
    
    bad( abs( D - GT ) > threshold ) = 1;
    
    result = ( sum( bad(:) ) / qtty_disp_in_D ) * 100;

end