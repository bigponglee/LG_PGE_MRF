function imagesc_para(map_range, para_gt, sub_title, varargin)
    % imagesc_para(para_gt, sub_title, varargin)
    % para_gt: ground truth of parameters
    % sub_title: cell array of sub_title
    % varargin: parameters to be compared with ground truth
    % example:
    % imagesc_para(para_gt, {'sub_title1', 'sub_title2'}, para1, para2);
    % imagesc_para(para_gt, {'sub_title1', 'sub_title2', 'sub_title3'}, para1, para2, para3);

    if length(sub_title) ~= length(varargin)
        error('sub_title and varargin must have the same length');
    end

    para_num = length(varargin) + 1;
    T1_value = map_range.T1_value;
    T1_value_error = map_range.T1_value_error;
    T2_value = map_range.T2_value;
    T2_value_error = map_range.T2_value_error;
    PD_value = map_range.PD_value;
    PD_value_error = map_range.PD_value_error;

    %% para maps show
    figure('Name', 'T1 T2 PD images', 'NumberTitle', 'off');
    colormap(hot);

    subplot(3, para_num, 1);
    imagesc(para_gt(:, :, 1), [0, T1_value]);
    title('T1 GT', 'FontSize', 12.5);
    axis off;
    axis image;
    colorbar;
    subplot(3, para_num, para_num + 1);
    imagesc(para_gt(:, :, 2), [0, T2_value]);
    title('T2 GT', 'FontSize', 12.5);
    axis off;
    axis image;
    colorbar;
    subplot(3, para_num, 2 * para_num + 1);
    imagesc(para_gt(:, :, 3), [0, PD_value]);
    title('PD GT', 'FontSize', 12.5);
    axis off;
    axis image;
    colorbar;

    for i = 1:para_num - 1
        subplot(3, para_num, i + 1);
        imagesc(varargin{i}(:, :, 1), [0, T1_value]);
        title(['T1 ', sub_title{i}], 'FontSize', 12.5);
        axis off;
        axis image;
        colorbar;
        subplot(3, para_num, para_num + i + 1);
        imagesc(varargin{i}(:, :, 2), [0, T2_value]);
        title(['T2 ', sub_title{i}], 'FontSize', 12.5);
        axis off;
        axis image;
        colorbar;
        subplot(3, para_num, 2 * para_num + i + 1);
        imagesc(varargin{i}(:, :, 3), [0, PD_value]);
        title(['PD ', sub_title{i}], 'FontSize', 12.5);
        axis off;
        axis image;
        colorbar;
    end

    %% error maps show
    figure('Name', 'Error maps', 'NumberTitle', 'off');
    colormap(hot);

    y_pos = size(para_gt, 1) + 12;

    for i = 1:para_num - 1
        nmse_T1 = goodnessOfFit(reshape(varargin{i}(:, :, 1), [], 1), reshape(para_gt(:, :, 1), [], 1), 'NMSE');
        nmse_T2 = goodnessOfFit(reshape(varargin{i}(:, :, 2), [], 1), reshape(para_gt(:, :, 2), [], 1), 'NMSE');
        nmse_PD = goodnessOfFit(reshape(varargin{i}(:, :, 3), [], 1), reshape(para_gt(:, :, 3), [], 1), 'NMSE');

        subplot(3, para_num - 1, i);
        imagesc(abs(varargin{i}(:, :, 1) - para_gt(:, :, 1)), [0, T1_value_error]);
        axis off;
        axis image;
        colorbar;
        title(['T1 ', sub_title{i}], 'FontSize', 20);
        text(20, y_pos, ['NMSE=', num2str(nmse_T1)], 'FontSize', 12.5);

        subplot(3, para_num - 1, i + para_num - 1);
        imagesc(abs(varargin{i}(:, :, 2) - para_gt(:, :, 2)), [0, T2_value_error]);
        axis off;
        axis image;
        colorbar;
        title(['T2 ', sub_title{i}], 'FontSize', 20);
        text(20, y_pos, ['NMSE=', num2str(nmse_T2)], 'FontSize', 12.5);

        subplot(3, para_num - 1, i + 2 * (para_num - 1));
        imagesc(abs(varargin{i}(:, :, 3) - para_gt(:, :, 3)), [0, PD_value_error]);
        axis off;
        axis image;
        colorbar;
        title(['PD ', sub_title{i}], 'FontSize', 20);
        text(20, y_pos, ['NMSE=', num2str(nmse_PD)], 'FontSize', 12.5);
    end

end
