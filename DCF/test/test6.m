
%%
addpath(genpath('../../DCF'));

I1 = imread('scene1.row3.col3.ppm');
I2 = imread('scene1.row3.col4.ppm');
GT = imread('truedisp.row3.col3.pgm');
scale = 16;
GT = GT / scale;

%% Test 2 - Aggregation Window for MRPG method

function_name = {"mrpg"};
agg_win = { 1, 5, 9, 13, 17, 19, 21 };
min_disp = 0;
max_disp = 15;
cost_function = 'SAD';
ref_img = 1; % it means that left image is the reference image

qtty_agg_win = length( agg_win );
result = NaN( qtty_agg_win, 1 );

for j=1:qtty_agg_win

    f1 = { {"set_images"}, {I1, I2}, {} };
    f2 = { {"check_images"}, {"before", "before"}, {} };
    f3 = { function_name, {"before", "before", min_disp, max_disp, ...
        cost_function, agg_win{j}, agg_win{j}, ref_img}, {"default"} };
    f4 = { {"rmse_metric"}, {"before", GT}, {} };

    params = { f1, f2, f3, f4 };

    [out1, out2] = dcf( params );
    
    result(j) = out2;
end
