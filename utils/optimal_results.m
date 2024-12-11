function [X_op, break_flag] = optimal_results(X, X_prev, SNR, SNR_prev, threshold)
    % OPTIMAL_RESULTS - Optimal results for the next iteration
    % function X = optimal_results(X, X_prev, SNR, SNR_prev)
    % Input:
    % X - current results
    % X_prev - previous optimal results
    % SNR - current SNR
    % SNR_prev - previous SNR
    % threshold - threshold for SNR
    % Output:
    % X_op - optimal results

    if SNR - SNR_prev > threshold
        X_op = X;
        break_flag = 0;
    else
        X_op = X_prev;
        break_flag = 1;
    end

end
