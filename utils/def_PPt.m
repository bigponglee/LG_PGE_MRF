function [P, Pt] = def_PPt(im_size, patch_size, stride)
    % def forward/backward patch operator
    % input: x - input image (3D array) size [im_size(1), im_size(2), im_size(3)]
    %        patch_size - size of the patch
    %        stride - stride of generating patches
    % output: P - forward operator
    %         Pt - backward operator

    % Compute the number of patches in each dimension
    num_rows = floor((im_size(1) - patch_size) / stride) + 1;
    num_cols = floor((im_size(2) - patch_size) / stride) + 1;

    weight = zeros(im_size); % weight for normalization

    for i_w = 1:num_rows

        for j_w = 1:num_cols
            row_start = (i_w - 1) * stride + 1;
            row_end = row_start + patch_size - 1;
            col_start = (j_w - 1) * stride + 1;
            col_end = col_start + patch_size - 1;
            weight(row_start:row_end, col_start:col_end, :) = ...
                weight(row_start:row_end, col_start:col_end, :) + 1;
        end

    end

    weight(weight == 0) = 1; % 0 cannot be a dividend

    function patches = patch_image(x)
        % Extract patches from the input image
        % input x: image
        % output patches: patches extracted from the image
        % patches is a 4D array of size [num_rows*num_cols, patch_size, patch_size, im_size(3)]
        patches = zeros(num_rows * num_cols, patch_size, patch_size, im_size(3));
        count = 0;

        for i = 1:num_rows

            for j = 1:num_cols
                count = count + 1;
                row_start = (i - 1) * stride + 1;
                row_end = row_start + patch_size - 1;
                col_start = (j - 1) * stride + 1;
                col_end = col_start + patch_size - 1;
                patches(count, :, :, :) = x(row_start:row_end, col_start:col_end, :);
            end

        end

        % [num_rows*num_cols, patch_size, patch_size, im_size(3)] -> [num_rows*num_cols, patch_size*patch_size*im_size(3)]
        patches = reshape(patches, num_rows * num_cols, patch_size * patch_size * im_size(3));
    end

    function x = unpatch_image(patches)
        % Reconstruct the image from the patches
        % input patches: patches extracted from the image
        % patches is a 4D array of size [num_rows*num_cols, patch_size, patch_size, im_size(3)]
        % output x: reconstructed image
        % x is a 3D array of size [im_size(1), im_size(2), im_size(3)]

        % [num_rows*num_cols, patch_size*patch_size*im_size(3)] -> [num_rows*num_cols, patch_size, patch_size, im_size(3)]
        patches = reshape(patches, num_rows * num_cols, patch_size, patch_size, im_size(3));
        x = zeros(im_size);
        count = 0;

        for i = 1:num_rows

            for j = 1:num_cols
                count = count + 1;
                row_start = (i - 1) * stride + 1;
                row_end = row_start + patch_size - 1;
                col_start = (j - 1) * stride + 1;
                col_end = col_start + patch_size - 1;
                x(row_start:row_end, col_start:col_end, :) = ...
                    x(row_start:row_end, col_start:col_end, :) + ...
                    reshape(patches(count, :, :, :), patch_size, patch_size, im_size(3));
            end

        end

        x = x ./ weight;
    end

    % Define the forward operator
    P = @(x) patch_image(x);

    % Define the backward operator
    Pt = @(x) unpatch_image(x);

end
