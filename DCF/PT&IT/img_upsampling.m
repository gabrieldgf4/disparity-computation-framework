
% After downsampling a image using img_dwonsampling, this function scale 
% the image according to scale parameter 

function [Iup] = img_upsampling(I, scale)

    [h1, w1, ~] = size(I);
    Iup = imresize(I, [h1*scale, w1*scale], 'nearest', 'Antialiasing', false);
    
end