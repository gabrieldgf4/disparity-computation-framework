%
% Default Parameters of the function used in the DCF platform
%
% Default values are stored in a container which has keys and values
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2021)

function default_parameters = original_params()

keySet = {'block_matching', 'subpixel_block_matching', 'bl', 'bl_asym',...
    'bl_asym_no_spatial', 'bl_no_spatial', 'fw', 'gf', 'lo', 'ml', 'mlmh',...
    'mrpg', 'mrpg_asym', 'mrpg_asym_v2', 'sb', 'sb_old', 'sw', 'vw', ...
    'brisk_detector', 'fast_detector', 'harris_detector', 'mser_detector', ...
    'surf_detector', 'abs_xdirection', ...
    'bilateral_filter', 'guided_filter', 'mean_filter', 'median_filter', ...
    'calibrated_rectify', 'uncalibrated_rectify', ...
    'badpixel_metric', 'rmse_metric', 'tar2ref_metric', ...
    'lr_check', 'lr_check_min', 'lr_check_min_disps', 'lc', 'scc', 'scc_v2', ...
    'segment_mode', 'superpixel_mode'};

%%% ----

block_matching_default = {};

subpixel_block_matching_default = {1/16};

bl_default = {7,36,33,33};
bl_asym_default = {7,36,33,33};
bl_asym_no_spatial_default = {7,33,33};
bl_no_spatial_default = {7,33,33};

fw_default = {};

gf_default = {19,0.0001};

lo_default = {0.009};

ml_default = {0.0009};
mlmh_default = {0.0009};

mrpg_default = {3,9,[1 1;1 1],6,35,35};
mrpg_asym_default = {3,9,[1 1;1 1],6,35,35};
mrpg_asym_v2_default = {3,9,[1 1;1 1],6,35,35};

sb_default = {0.01};
sb_old_default = {0.01};

sw_default = {};

vw_default = {4,31,1.5,7,-2};

%%% ----

brisk_detector_default = {};
fast_detector_default = {};
harris_detector_default = {};
mser_detector_default = {};
surf_detector_default = {};

abs_xdirection_default = {};

bilateral_filter_default = {650,1};
guided_filter_default = {5,5};
mean_filter_default = {5,5};
median_filter_default = {5,5};

calibrated_rectify_default = {};
uncalibrated_rectify_default = {};

badpixel_metric_default = {};
rmse_metric_default = {};
tar2ref_metric_default = {};

lr_check_default = {1,0.1,9,19};
lr_check_min_default = {1};
lr_check_min_disps_default = {};

lc_default = {12,30,25,69,0,15,39,39};
scc_default = {39,18,7,7,5,1,[23,14],39,39};
scc_v2_default = {1,18,1,1,1,[23,14],39,39,0};
segment_mode_default = {7,7,5};
superpixel_mode_default = {2000,10,1,'mean',0};

valueSet = {block_matching_default, subpixel_block_matching_default,...
    bl_default, bl_asym_default, bl_asym_no_spatial_default, ...
    bl_no_spatial_default, fw_default, gf_default, lo_default, ...
    ml_default, mlmh_default, mrpg_default, mrpg_asym_default, mrpg_asym_v2_default ...
    sb_default, sb_old_default, sw_default, vw_default, ...
    brisk_detector_default, fast_detector_default, harris_detector_default, ...
    mser_detector_default, surf_detector_default, abs_xdirection_default, ...
    bilateral_filter_default, guided_filter_default, mean_filter_default, ...
    median_filter_default, calibrated_rectify_default, uncalibrated_rectify_default, ...
    badpixel_metric_default, rmse_metric_default, tar2ref_metric_default, ...
    lr_check_default, lr_check_min_default, lr_check_min_disps_default, ...
    lc_default, scc_default, scc_v2_default, segment_mode_default, ...
    superpixel_mode_default};

default_parameters = containers.Map(keySet, valueSet);

end