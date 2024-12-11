function [X_recon, para_maps_recon, SNR, ms_time] = lgpge_solver(b, X_gt, D, A, At, AtA, P_X, Pt_X, P_para, dic_matching, para)
    % [X_recon, para_maps_recon, SNR, ms_time] = manigold_solver(b, X_gt, D, A, At, AtA, P_X, Pt_X, P_para, dic_matching, para)
    % reconstruction using manifold regularization
    % b: observed data
    % X_gt: ground truth
    % D: dictionary
    % A: forward operator
    % At: adjoint operator
    % AtA: At*A
    % P_X: projection operator
    % Pt_X: adjoint projection operator
    % P_para: projection operator for parameters
    % dic_matching: dictionary matching function
    % para: parameters

    %% 初始化
    atb = At(b); % atb
    para_maps = dic_matching(atb); % M0
    para_patches = P_para(para_maps);
    [Laplacian_matrix, lambda_1, lambda_2] = calc_patches_distance_lgpge(para_patches, para.th, para.lambda_1, para.lambda_2, para);
    X_recon = atb;

    %% 投影算子 projection operator
    base = orth(D.'); % L*r
    base = base.'; % r*L
    pinv_D = pinv(base); %Moore-Penrose Pseudoinverse 逆 L*r
    Proj_D = pinv_D * base; %projection operator L*L

    %% iteration 迭代求解
    SNR = [];
    SNR_iter = 20 * log10(norm(X_gt(:)) / norm(atb(:) - X_gt(:)));
    fprintf('iter: %d----> SNR: %6.4f; Lambda_1: %.6f; Lambda_2: %.6f \n', 0, SNR_iter, lambda_1, lambda_2);
    SNR = [SNR, SNR_iter];
    X = atb;
    U = X;
    tic;
    t = para.t;
    acc =para.acc;
    mu = para.mu;

    for i = 1:para.max_iter
        X_prev = X;
        % gradient descent
        X = U - mu * (AtA(U) - atb + manifold_cg(U, Laplacian_matrix, P_X, Pt_X, 1.0, para.res, 0));
        % projection
        X = reshape(X, para.res(1) * para.res(2), para.res(3)) * Proj_D;
        X = reshape(X, para.res);

        %Accelerated:
        if acc ==1
            t_prev = t;
            t = 0.5 * (1 + sqrt(1 + 4 * t ^ 2));
            U = X + ((t_prev - 1) / t) * (X - X_prev);
        else
            U = X;
        end

        % update L
        para_maps = dic_matching(X);
        para_patches = P_para(para_maps);
        [Laplacian_matrix, lambda_1, lambda_2] = calc_patches_distance_lgpge(para_patches, para.th, lambda_1, lambda_2, para);
        % calculate loss
        SNR_iter = 20 * log10(norm(X_gt(:)) / norm(X(:) - X_gt(:)));
        fprintf('iter: %d----> SNR: %6.4f; Lambda_1: %.6f; Lambda_2: %.6f \n', i, SNR_iter, lambda_1, lambda_2);
        SNR = [SNR, SNR_iter];

        [X_recon, break_flag] = optimal_results(X, X_recon, SNR(end), SNR(end - 1), para.threshold);


         if break_flag
            if acc == 0
                break;
            end
        end

        if break_flag
            acc = 0;
            U = X_recon;
            break_flag = 0;
        end

    end

    ms_time = toc; %算法运行时间
    ms_time = ms_time / 60; %in min
    figure('Name', 'SNR', 'NumberTitle', 'off');
    plot(gather(SNR));
    title('SNR');
    drawnow;
    grid on;
    fprintf('manifold solving time: %.2f min\n', ms_time)
    para_maps_recon = dic_matching(X_recon);
end
