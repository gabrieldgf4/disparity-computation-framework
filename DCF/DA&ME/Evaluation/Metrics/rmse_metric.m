
% Root mean square error
%
% D - Disparity map
% GT - ground truth map
%
% D and GT must be provided by the user


function [D, result] = rmse_metric(D, GT)

D = double(D);
GT = double(GT);

    D( isnan(D) ) = 0;
    GT( isnan(D) ) = 0;

    result = sqrt(immse(D, GT));

end