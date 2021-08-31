
% Return both disparity maps. It is useful to use lr_check as
% post-processing technique 
function [D1, D2] = prepare_bothDM(function_name, function_parameters)

parameters = function_parameters{:};

function_handle = str2func( function_name );
[out1, out2] = function_handle( function_parameters{:} );

end