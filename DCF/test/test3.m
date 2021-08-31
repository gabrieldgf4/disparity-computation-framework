
%%
addpath(genpath('../../DCF'));

I1 = imread('scene1.row3.col3.ppm');
I2 = imread('scene1.row3.col4.ppm');
GT = imread('truedisp.row3.col3.pgm');
scale = 16;
GT = GT / scale;

%% Test 3 - Compare dense stereo methodos considering pre-filtering and post-processing

functions_name = {"bl", "bl_no_spatial", "fw", "gf", "lo", "mlmh", "mrpg", "sb", "sw", "vw"};
agg_win = 3;
cost_function = "TAD_C+G";
min_disp = 0;
max_disp = 15;
ref_img = "left"; % it means that left image is the reference image

qtty_functions = length( functions_name );
result = NaN( 3, qtty_functions );

for i=1:qtty_functions     
    
    f1 = { {"set_images"}, {I1, I2}, {} };
    f2 = { {"check_images"}, {"before", "before"}, {} };
    f3 = { {"median_filter"}, {"before", "before", agg_win, agg_win}, {} };
    f4 = { functions_name{i}, {"before", "before", min_disp, max_disp, ...
        cost_function, agg_win, agg_win, ref_img}, {"default"} };
    f5 = { {"scc"}, {"before", I1}, {"default"} };
    f6 = { {"badpixel_metric"}, {"before", GT, 1}, {} };

    params = { f1, f2, f4, f6 }; % w/o pre-filtering and post-processing
    [~, out2] = dcf( params );
    result(1, i) = out2;
    
    params = { f1, f2, f3, f4, f6 }; % w/ pre-filtering
    [~, out2] = dcf( params );
    result(2, i) = out2;
    
    params = { f1, f2, f3, f4, f5, f6 }; % w/ pre-filtering and post-processing
    [out1, out2] = dcf( params );
    result(3, i) = out2;
    
    % save visual results, i.e., the disparity maps
    % figure; imagesc(out1); colormap gray;
    % save_from_imshow(functions_name{i}, "png");
    
end
