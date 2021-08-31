
%%
addpath(genpath('../../DCF'));

I1 = imread('scene1.row3.col3.ppm');
I2 = imread('scene1.row3.col4.ppm');
GT = imread('truedisp.row3.col3.pgm');
scale = 16;
GT = GT / scale;

%% Test 2 - Aggregation Window

functions_name = {"bl", "fw", "gf", "lo", "mlmh", "mrpg", "sb", "sw", "vw"};
agg_win = { 1, 5, 9, 13, 17, 19, 21 };
min_disp = 0;
max_disp = 15;
cost_function = 'SAD';
ref_img = 1; % it means that left image is the reference image

qtty_functions = length( functions_name );
qtty_agg_win = length( agg_win );
result = NaN( qtty_functions, qtty_agg_win );

for i=1:qtty_functions
    for j=1:qtty_agg_win

    f1 = { {"set_images"}, {I1, I2}, {} };
    f2 = { functions_name(i), {"before", "before", min_disp, max_disp, ...
        cost_function, agg_win{j}, agg_win{j}, ref_img}, {"default"} };
    f3 = { {"rmse_metric"}, {"before", GT}, {} };

    params = { f1, f2, f3 };

    [out1, out2] = dcf( params );
    
    result(i,j) = out2;
    end
end
