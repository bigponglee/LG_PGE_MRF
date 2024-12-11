function [L, lambda_1, lambda_2] = calc_patches_distance_lgpge(a, th, lambda_1, lambda_2, para)
    % calculate the distance between patches
    % input
    %   a: patches [patch_nums, patch_size]
    %   sig: sigma for the exponential weights
    %   th: threshold for the exponential weights
    % output
    %   L normlized Laplacian matrix

    % (a-b)^2 = a^2 + b^2 - 2ab

    in_size = size(a);

    ab = a * a'; % [patch_nums, patch_nums]
    a = sum(a .^ 2, 2); % [patch_nums, 1]

    a2 = repmat(a, [1, in_size(1)]);
    b2 = repmat(a', [in_size(1), 1]);

    dis = abs(a2 + b2 - 2 * ab); % [patch_nums, patch_nums]
    dis_max = repmat(max(dis, [], 2), [1, in_size(1)]);
    dis_max(dis_max == 0) = 1.0;
    dis = dis ./ dis_max; % normlized distance

    % locality preserving
    W = exp(-dis / (2 * para.sig ^ 2)); % exponential weights [patch_nums, patch_nums]

    W_max = repmat(max(W, [], 2), [1, in_size(1)]);
    W_max(W_max == 0) = 1.0;

    W = W ./ W_max; % [patch_nums, patch_nums]

    W(W < th) = 0; % [patch_nums, patch_nums]

    D = diag(sum(W, 1)); % [patch_nums, patch_nums]
    L_local = D - W; % Laplacian matrix [patch_nums, patch_nums]

    % global preserving
    W_global = exp(dis / (2 * para.sig_2 ^ 2)); % exponential weights [patch_nums, patch_nums]
    W_global(W>0) =0;
    W_global(W_global>1e32)=1e32;
    W_max = repmat(max(W_global, [], 2), [1, in_size(1)]);
    W_max(W_max == 0) = 1.0;

    W_global = W_global ./ W_max; % [patch_nums, patch_nums]

    W_global(W_global < th) = 0; % [patch_nums, patch_nums]
    D_global = diag(sum(W_global, 1)); % [patch_nums, patch_nums]
    L_global = D_global - W_global; % Laplacian matrix [patch_nums, patch_nums]
    
    if max(L_local(:))>0
        lambda_1 = para.lambda_1 ./ max(L_local(:));
    end
    if max(L_global(:))>0
        lambda_2 = para.lambda_2 ./ max(L_global(:));
    end

    L = lambda_1.*L_local - lambda_2.*L_global;
end
