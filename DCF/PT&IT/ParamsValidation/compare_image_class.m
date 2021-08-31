
function compare_image_class(I1, I2)

    if ~strcmp( class(I1), class(I2) )
        error( 'Error. Images must have the same class');
    end
    
end