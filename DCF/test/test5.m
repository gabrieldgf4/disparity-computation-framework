
%%
addpath(genpath('../../DCF'));

I1 = imread('GEDC5880.jpg');
I2 = imread('GEDC5886.jpg');

load calibrationSession.mat;
cameraParams = calibrationSession.CameraParameters;

%% Test 5 - Rectify images with calibrated cameras

functions_name = {"bl", "bl_no_spatial", "fw", "gf", "lo", "mlmh", "mrpg", "sb", "sw", "vw"};
agg_win = 3;
cost_function = "BTSAD";
min_disp = 0;
max_disp = 65;

qtty_functions = length( functions_name );
result = NaN( 1, qtty_functions );

    f1 = { {"set_images"}, {I1, I2}, {} };
    f2 = { {"check_images"}, {"before", "before"}, {} };   
    f3 = { {"calibrated_rectify"}, {"before", "before", cameraParams}, {} };
    f4 = { {"median_filter"}, {"before", "before", 15, 15}, {} };
    
    [I1r, I2r] = dcf( { f1, f2, f3, f4 } );
    
    % resize images to avoid Matlab error: array exceeds maximum array size preference
    scale = 6;
    [I1rec, I1new] = img_downsampling(I1r, scale);
    [I2rec, I2new] = img_downsampling(I2r, scale);
    %
for i=1:qtty_functions     
    
    f5a = { functions_name{i}, {I1rec, I2rec, min_disp, max_disp, ...
        cost_function, agg_win, agg_win, "left"}, {"default"} };
    [D1, ~] = dcf( { f5a } );
    
    f5b = { functions_name{i}, {I1rec, I2rec, min_disp, max_disp, ...
        cost_function, agg_win, agg_win, "right"}, {"default"} };
    [D2, ~] = dcf( { f5b } );
    
    f6 = { {"lr_check"}, {D1, D2, I1rec, min_disp, max_disp}, {"default"} };
    f7 = { {"tar2ref_metric"}, {"before", I1rec, I2rec, 1}, {} };
    [out1, out2] = dcf( { f6, f7 } );
    result(i) = out2;
    
    % save visual results, i.e., the disparity maps
    figure; imagesc(out1(45:565,115:830)); colormap gray;
    save_from_imshow(functions_name{i}, "png");
    
    % upsampling the disparity map
    % Dup = img_upsampling(out1, scale);
    
    %figure; imshowpair(I1new, Dup); 
       
end


