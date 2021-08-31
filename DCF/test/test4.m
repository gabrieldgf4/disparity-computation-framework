
%%
addpath(genpath('../../DCF'));

I1 = imread('scene1.row3.col3.ppm');
I2 = imread('scene1.row3.col4.ppm');
GT = imread('truedisp.row3.col3.pgm');
scale = 16;
GT = GT / scale;

%% Test 4 - Compare sparse stereo approaches

functions_name = {"brisk_detector", "fast_detector", "harris_detector", ...
    "mser_detector", "surf_detector"};

qtty_functions = length( functions_name );
result = NaN( 1, qtty_functions );

for i=1:qtty_functions     
    
    f1 = { {"set_images"}, {I1, I2}, {} };
    f2 = { {"check_images"}, {"before", "before"}, {} };      
    f3 = { functions_name{i}, {"before", "before"}, {} };
    f4 = { {"abs_xdirection"}, {"before", "before", I1}, {} };
    f5 = { {"rmse_metric"}, {"before", GT}, {} };
    
    params = { f1, f2, f3, f4, f5 }; 
    [out1, out2] = dcf( params );
    result(1,i) = out2;
    
    valid_poinsts = (out1 > 0);
    result(2,i) = sum(valid_poinsts(:)); % qtty of matched points between I1 and I2
    
end
