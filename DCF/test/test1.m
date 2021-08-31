
%%
addpath(genpath('../../DCF'));

I1 = imread('scene1.row3.col3.ppm');
I2 = imread('scene1.row3.col4.ppm');
GT = imread('truedisp.row3.col3.pgm');
scale = 16;
GT = GT / scale;

%% Test 1 - Execute MRPG method

function_name = {"mrpg"};
agg_win = 3;
min_disp = 0;
max_disp = 15;
cost_function = "SAD";
ref_img = "left"; % it means that left image is the reference image

    f1 = { function_name, {I1, I2, min_disp, max_disp, ...
        cost_function, agg_win, agg_win, ref_img}, {"default"} };

    params = { f1 };
    [out1, out2] = dcf( params );
    