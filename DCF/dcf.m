
%
% Controller of the Disparity Computation Framework (DCF)
%
%   input_params - parameters defined by the user to be applied in the
%   three layer DCF architecture
%
%   out1 - first output
%   out2 - second output
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2021)


function [out1, out2] = dcf( functions )

out1 = [];
out2 = [];

    for i = 1:length(functions)
                        
        function_parameters = verify_parameters( functions{i}, out1, out2 );
        
        % Get a String and convert it to a function
        function_name = functions{i}{1}{1};
        function_handle = str2func( function_name );

        [out1, out2] = function_handle( function_parameters{:} );
        
    end
end

function function_parameters = verify_parameters( func, out1, out2 )
    
    if length( func ) ~= 3
        error('Error. Function %s must have 3 cell parameters, not %i.',...
            func{1}{1}, length(func));
    end

    function_parameters1 = func{2};
    function_parameters2 = func{3};
    
    cellArray = {func{2}{:}};
    cellArray(~cellfun(@isstring,cellArray)) = {NaN};
    
    flag_before = find( strcmp( [ cellArray{:} ], "before" ), 1 );
    if ~isempty( flag_before )
        function_parameters1 = is_out_in( func, out1, out2 );
    end
    
    flag_left = find( strcmp( [ cellArray{:} ], "left" ), 1 );
    if ~isempty( flag_left )
        function_parameters1(flag_left) = {1};
    end
    
    flag_right = find( strcmp( [ cellArray{:} ], "right" ), 1 );
    if ~isempty( flag_right )
        function_parameters1(flag_right) = {-1};
    end

    flag_default = find( strcmp( [func{3}{:}], "default" ), 1 );
    if ~isempty( flag_default )
        function_parameters2 = default_parameters( func );
    end
    
    function_parameters = [ function_parameters1, function_parameters2 ];

end

% check if the default values were requested, if not, proceed
function function_parameters = default_parameters( func )
    
    func_name = func{1}{1};
    original_parameters = original_params( );
    function_parameters = original_parameters( func_name );
    
end

% check if the result of a function will be used as input at that time
function function_parameters = is_out_in(func, out1, out2 ) 

    function_parameters = func{2};
    if strcmp( function_parameters{1}, "before" )
        function_parameters{1} = out1;
    end  
    if strcmp( function_parameters{2}, "before" )
        function_parameters{2} = out2;
    end 
    
end

        
