
%%
addpath(genpath('../../DCF'));

I1 = imread('scene1.row3.col3.ppm');
I2 = imread('scene1.row3.col4.ppm');
GT = imread('truedisp.row3.col3.pgm');
scale = 16;
GT = GT / scale;

%% Test 5 - Parameters Optmization - Aggregation Window x Cost Functions for MRPG method

function_name = {"mrpg"};
agg_win = { 1, 5, 9, 13, 17, 19, 21 };
cost_functions = {"AFF", "BTSAD", "BTSSD", "LIN", "NCC", "SAD", "SSD", ...
    "SSDNorm", {"STAD",20}, "TAD_C+G", "ZSSD"};
min_disp = 0;
max_disp = 15;
ref_img = 1; % it means that left image is the reference image

qtty_cost_functions = length( cost_functions );
qtty_agg_win = length( agg_win );
result = NaN( qtty_cost_functions, qtty_agg_win );

for i=1:qtty_cost_functions
    for j=1:qtty_agg_win

        f1 = { function_name, {I1, I2, min_disp, max_disp, ...
            cost_functions{i}, agg_win{j}, agg_win{j}, ref_img}, {"default"} };
        f3 = { {"rmse_metric"}, {"before", GT}, {} };

        params = { f1, f3 };

        [out1, out2] = dcf( params );

        result(i,j) = out2;
    end
end
