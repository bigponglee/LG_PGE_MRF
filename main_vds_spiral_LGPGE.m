clc;
close all;
clear all;
clear classes;
%% add path
addpath('utils/');
addpath('py_func/')
%% 初始化参数设置
para.out_path = '/media/deep/E/lp/output_msllr/500_vds_noisy/'; %输出文件路径
if(~exist(para.out_path,'file'))             % 如果不存在有Results的file，那就返回非0 
    mkdir(para.out_path);                    % 生成新的Results的file
end
para.save_flag = 0;

para.Nx = 128; %图像尺寸Nx*Ny
para.Ny = 128;
para.L = 500; %序列长度L
para.res = [para.Nx, para.Ny, para.L];
para.para_res = [para.Nx, para.Ny, 3];
para.noisy = 1; %是否添加噪声
para.matching_var = 0.9; % 匹配阈值
para.matching_batch = 10000; % 同时最大匹配条目batch size
para.PD_norm = 116.8877;

para.max_iter = 50; %求解迭代最大次数
para.threshold = 1e-2; % iteration stopping criterion
para.threshold_cg = 1e-5; % threshold for CG algorithm
para.cg_max_iter = 30;
para.patch_size = 1; % for PPt OPERATOR
para.stride = 1; % 步长越大速度越快
para.sig = 1e-2; % parameter for LOCAL
para.sig_2 = 1e-2; 
para.th = 0.0; % threshold for the exponential weights
para.mu = 0.75; % step size for gradient descent
para.beta = 5; % threshold for SVT
para.lambda_1 = 1e-1; % locality preserving regularization parameter
para.lambda_2 = 1e-3; % global preserving regularization parameter

para.acc = 1; % acceleration flag
para.t = 1; % parameter for the acceleration

map_range.T1_value = 2500;
map_range.T1_value_error = 500;
map_range.T2_value = 500;
map_range.T2_value_error = 200;
map_range.PD_value = 116.8877;
map_range.PD_value_error = 23.3775;
%%  load py function
py.importlib.reload(py.importlib.import_module('py_func.dic_matching'));
py.importlib.reload(py.importlib.import_module('py_func.build_dic_matrix'));
py.importlib.reload(py.importlib.import_module('py_func.nufft_for_matlab')); %single coil
%% 数据加载
load('data/input_to_fisp_experiment.mat') %仿真参数图 T1_128 T2_128 PD_128
load("data/fatr.mat") %FISP序列参数 fa tr
load('data/vds_spiral_ktraj.mat') %variable density spiral变密度螺旋采样模板 ktraj
fa = fa(1:para.L);
tr = tr(1:para.L);
ktraj = ktraj(1:para.L, :, :) * 2 * pi; %to pi
%% nufft init
% matlab调用python初始化可能会比较慢
torch_batch_size = 1000; %nufft使用PyTorch实现，batch size越大速度越快，需显存越大
grid_factor = 2; % nufft grid factor  越大精度越高，计算开销越大
py.py_func.nufft_for_matlab.init_nufft_op(torch_batch_size, para.Nx, para.Ny, para.L, grid_factor, ...
py.numpy.array(ktraj)) %single coil
%% build Dictionary
tic;
tmp = py.py_func.build_dic_matrix.build_dictionary_mat(py.numpy.array(fa), py.numpy.array(tr));
D = double(tmp{'dic'});
D = single(D);
LUT = double(tmp{'lut'});
time_build_D = toc;
fprintf('build Dictionary time: %.4f s; \n', time_build_D)
%% build X
tic;
tmp = py.py_func.build_dic_matrix.build_TemplateMatrix_mat(py.numpy.array(fa), ...
    py.numpy.array(tr), py.numpy.array(T1_128), py.numpy.array(T2_128), py.numpy.array(PD_128));
X = double(tmp);
X = single(X);
para_maps = cat(3, T1_128, T2_128, PD_128);
para_maps_mask = cat(3, T1_128 > 10, T2_128 > 10, PD_128 > 0);
time_build_X = toc;
fprintf('build X time: %.4f s; \n', time_build_X)
para.m_abs = max(abs(X(:))); % 归一化
Y = fft2(X ./ para.m_abs);
%% dictionary matching
dic_matching = def_matching(D, LUT, para.matching_var, para.matching_batch); % matching operator
para_maps_gt = dic_matching(X);
para_maps_gt = para_maps_gt .* para_maps_mask;
%% ratio downsampling
[A_spiral, At_spiral, AtA_spiral] = defAAt_spiral(para.m_abs);
[P_X, Pt_X] = def_PPt(para.res, para.patch_size, para.stride); % PPt operator for X
[P_para, Pt_para] = def_PPt(para.para_res, para.patch_size, para.stride); % PPt operator for M

Y_down = A_spiral(X);
% 高斯噪声
if para.noisy == 1
    kSpaceNoise = reshape([1, 1i] * 0.25 * randn(2, para.L * para.Nx * para.Ny), para.res);
    n = A_spiral(kSpaceNoise);
    Y_down = Y_down + n;
end
%% LG-PGE solver
[X_recon_lgpge, para_maps_recon_lgpge, SNR_lgpge, lgpge_time] = lgpge_solver(Y_down, X, D, A_spiral, At_spiral, AtA_spiral, P_X, Pt_X, P_para, dic_matching, para);
para_maps_recon_lgpge = para_maps_recon_lgpge .* para_maps_mask;
%% show results
imagesc_para(map_range, para_maps_gt, {'LGPGE'}, para_maps_recon_lgpge)
