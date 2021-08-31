
%%
addpath(genpath('../../DCF'));

I1 = imread('scene1.row3.col3.ppm');
I2 = imread('scene1.row3.col4.ppm');
GT = imread('truedisp.row3.col3.pgm');
scale = 16;
GT = GT / scale;

%% Test 3 - Cost Functions

functions_name = {"bl", "fw", "gf", "lo", "mlmh", "mrpg", "sb", "sw", "vw"};
agg_win = { 5, 13, 5, 1, 1, 5, 21, 21, 1 };
cost_functions = {"AFF", "BTSAD", "BTSSD", "LIN", "NCC", "SAD", "SSD", ...
    "SSDNorm", "STAD", "TAD_C+G", "ZSSD"};
min_disp = 0;
max_disp = 15;
ref_img = 1; % it means that left image is the reference image

qtty_functions = length( functions_name );
qtty_cost_functions = length( cost_functions );
result = NaN( qtty_functions, qtty_cost_functions );

for i=1:qtty_functions
    for j=1:qtty_cost_functions

    f1 = { {"set_images"}, {I1, I2}, {} };
    f2 = { functions_name(i), {"before", "before", min_disp, max_disp, ...
        cost_functions{j}, agg_win{i}, agg_win{i}, ref_img}, {"default"} };
    f3 = { {"rmse_metric"}, {"before", GT}, {} };

    params = { f1, f2, f3 };

    [out1, out2] = dcf( params );
    
    result(i,j) = out2;
    end
end
