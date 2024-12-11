function dic_matching = def_matching(D, LUT, matching_var, matching_batch)
    % function dic_matching = def_matching(D, LUT, matching_var, matching_batch)
    % define the matching function
    % input
    %   D: dictionary [para_num, L]
    %   LUT: look up table [para_num, 2]
    %   matching_var: matching threshold
    %   matching_batch: batch size for matching
    %   PD_norm: PD normlized factor
    % output
    %   dic_matching: matching function

    function para_maps_recon = matching_def(X_recon)
        % function para_maps_recon = matching_def(X_recon)
        % matching function
        % input
        %   X_recon: reconstructed images [N, N, L]
        % output
        %   para_maps_recon: reconstructed parameter maps [N, N, 3]

        tmp = py.py_func.dic_matching.build_maps_mat(py.numpy.array(X_recon), ...
        py.numpy.array(D), py.numpy.array(LUT), matching_var, matching_batch);
        T1_recon = double(tmp{'t1'});
        T2_recon = double(tmp{'t2'});
        PD_recon = double(tmp{'m0'});
        para_maps_recon = cat(3, T1_recon, T2_recon, PD_recon);
    end

    dic_matching = @(x) matching_def(x);

end
