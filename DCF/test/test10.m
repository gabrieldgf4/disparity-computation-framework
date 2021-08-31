
%%
addpath(genpath('../../DCF'));

I1 = imread('scene1.row3.col3.ppm');
I2 = imread('scene1.row3.col4.ppm');
GT = imread('truedisp.row3.col3.pgm');
scale = 16;
GT = GT / scale;

%% Test 3_2 - Aggregation Window x Cost Function for all disparity calculation methods

functions_name = {"bl", "fw", "gf", "lo", "mlmh", "mrpg", "sb", "sw", "vw"};
agg_win = { 1, 5, 9, 13, 17, 19, 21 };
cost_functions = {"AFF", "BTSAD", "BTSSD", "LIN", "NCC", "SAD", "SSD", ...
    "SSDNorm", {"STAD",30}, "TAD_C+G", "ZSSD"};
min_disp = 0;
max_disp = 15;
ref_img = 1; % it means that left image is the reference image

qtty_functions = length( functions_name );
qtty_cost_functions = length( cost_functions );
qtty_agg_win = length( agg_win );
result = NaN( qtty_functions, qtty_cost_functions, qtty_agg_win );

for k=1:qtty_functions
    for i=1:qtty_cost_functions
        for j=1:qtty_agg_win

            f1 = { {"set_images"}, {I1, I2}, {} };
            f2 = { {"check_images"}, {"before", "before"}, {} };
            f3 = { functions_name{k}, {"before", "before", min_disp, max_disp, ...
                cost_functions{i}, agg_win{j}, agg_win{j}, ref_img}, {"default"} };
            f4 = { {"rmse_metric"}, {"before", GT}, {} };

            params = { f1, f2, f3, f4 };

            [out1, out2] = dcf( params );

            result(k,i,j) = out2;
        end
    end
end
