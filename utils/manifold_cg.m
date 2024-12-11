function result = manifold_cg(x, L, P, P_t, lambda, res, is_reshape)
    % x: input image [N,N,L]
    % L: Laplacian matrix [patch_num, patch_num]
    % P: patch operator
    % P_t: transpose of patch operator
    % lambda: regularization parameter
    % res: image resolution [N,N,L]
    % is_reshape: if x is reshaped to [N*N,L]

    x = reshape(x, res);
    Px = P(x); % [patch_num, patch_sizes]
    PxL = Px' * L; % [patch_sizes, patch_num]
    PtPxL = P_t(PxL'); % [N,N,L]

    if is_reshape == 1
        result = lambda * PtPxL(:);
    else
        result = lambda * PtPxL;
    end

end
