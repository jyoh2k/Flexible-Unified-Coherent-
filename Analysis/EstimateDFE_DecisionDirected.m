%% ========================================================================
% EstimateDFE_DecisionDirected_v2014a
% MATLAB 2014a 완전 호환 버전
% ========================================================================

function [w_ffe_dd, f_fbe_dd, result] = ...
    EstimateDFE_DecisionDirected(y_rx, x_tx, N_ffe, N_fbe, varargin)

% 입력 파�?�미터 처리
max_iter = 3;
soft_limiting = true;
OS_factor = 1;
debug_mode = false;
pam4_levels = [-3, -1, 1, 3];

% varargin 처리 (간단한 방�?)
for idx = 1:2:length(varargin)
    param_name = varargin{idx};
    param_value = varargin{idx+1};
    
    if strcmp(param_name, 'MaxIterations')
        max_iter = param_value;
    elseif strcmp(param_name, 'SoftLimiting')
        soft_limiting = param_value;
    elseif strcmp(param_name, 'OversamplingFactor')
        OS_factor = param_value;
    elseif strcmp(param_name, 'DebugMode')
        debug_mode = param_value;
    elseif strcmp(param_name, 'pam4_levels')
        pam4_levels = param_value;
    end
end

if debug_mode
    fprintf('\n');
    fprintf('========================================\n');
    fprintf('Decision-Directed DFE (v2014a)\n');
    fprintf('========================================\n');
    fprintf('Iteration 0: Ideal transmit symbols\n');
    fprintf('----------------------------------------\n');
end

% =====================================================================
% Step 1: Initial estimation with transmit symbols
% =====================================================================

[w_ffe, f_fbe, result] = EstimateDFECoefficients(...
    y_rx, x_tx, N_ffe, N_fbe, ...
    'OversamplingFactor', OS_factor);

if debug_mode
    fprintf('Initial w_ffe[1:min(3,length)] = [');
    for i = 1:min(3, length(w_ffe))
        fprintf('%.4f', w_ffe(i));
        if i < min(3, length(w_ffe))
            fprintf(', ');
        end
    end
    fprintf(']\n');
    if length(f_fbe) >= 2
        fprintf('Initial f_fbe = [%.4f, %.4f]\n', f_fbe(1), f_fbe(2));
    end
end

% Initialize history
ber_history = [];
coeff_change_history = [];

% =====================================================================
% Step 2: Iterative refinement
% =====================================================================

for iter = 1:max_iter
    if debug_mode
        fprintf('\nIteration %d:\n', iter);
        fprintf('----------------------------------------\n');
    end
    
    % Step 2a: DFE output
    x_hat = dfe_output_v2014a(y_rx, w_ffe, f_fbe, result.main_cursor_idx, OS_factor);
    
    % Step 2b: Decision (slicing)
    d_hat = pam4_slice_v2014a(x_hat, pam4_levels);
    
    % Step 2c: Calculate BER
    ber = mean(x_tx ~= d_hat);
    ber_history = [ber_history; ber];
    
    if debug_mode
        fprintf('  SER: %.4e\n', ber);
    end
    
    % Step 2d: Soft-limiting blending
    if soft_limiting
        alpha = iter / max_iter;
    else
        alpha = 1.0;
    end
    
    y_target = alpha * d_hat + (1 - alpha) * x_tx;
    
    if debug_mode
        fprintf('  Alpha: %.2f\n', alpha);
    end
    
    % Step 2e: Re-estimate
    [w_ffe_new, f_fbe_new, result_new] = EstimateDFECoefficients(...
        y_rx, y_target, N_ffe, N_fbe, ...
        'OversamplingFactor', OS_factor, ...
        'DebugMode', false);
    
    % Step 2f: Coefficient change
    coeff_change = max([
        max(abs(w_ffe - w_ffe_new));
        max(abs(f_fbe - f_fbe_new))
    ]);
    
    coeff_change_history = [coeff_change_history; coeff_change];
    
    if debug_mode
        fprintf('  Coeff change: %.6e\n', coeff_change);
    end
    
    % Update
    w_ffe = w_ffe_new;
    f_fbe = f_fbe_new;
    result = result_new;
    
    % Check convergence
    if coeff_change < 1e-5 && ber < 0.01
        if debug_mode
            fprintf('  CONVERGED!\n');
        end
        break;
    end
    
    if debug_mode
        fprintf('  w_ffe[1] = %.4f, f_fbe[1] = %.4f\n', w_ffe(1), f_fbe(1));
    end
end

% =====================================================================
% Output
% =====================================================================

w_ffe_dd = w_ffe;
f_fbe_dd = f_fbe;

result.num_iterations = iter;
result.method = 'Decision-Directed';
result.ber_history = ber_history;
result.coeff_change_history = coeff_change_history;

if debug_mode
    fprintf('\n');
    fprintf('========================================\n');
    fprintf('Complete!\n');
    fprintf('Iterations: %d\n', iter);
    fprintf('Final SER: %.4e\n', ber_history(end));
    fprintf('========================================\n\n');
end

end

% =========================================================================
% Helper: DFE Output (2014a compatible)
% =========================================================================

function x_hat = dfe_output_v2014a(y_rx, w_ffe, f_fbe, main_cursor, OS_factor)

N_ffe = length(w_ffe);
N_fbe = length(f_fbe);
K = floor(length(y_rx) / OS_factor);

x_hat = zeros(K, 1);
d_register = zeros(N_fbe, 1);

for k = 1:K
    % FFE
    ffe_out = 0;
    for i = 0:N_ffe-1
        offset = i - (main_cursor - 1);
        sample_idx = (k-1) * OS_factor + main_cursor + offset;
        
        if sample_idx >= 1 && sample_idx <= length(y_rx)
            ffe_out = ffe_out + w_ffe(i+1) * y_rx(sample_idx);
        end
    end
    
    % FBE
    fbe_out = 0;
    if N_fbe > 0
        fbe_out = f_fbe' * (-d_register);
    end
    
    % Output
    x_hat(k) = ffe_out + fbe_out;
    
    % Update register
    d_hat_k = round(x_hat(k));
    d_register = [d_hat_k; d_register(1:end-1)];
end

end

% =========================================================================
% Helper: PAM4 Slicing (2014a compatible)
% =========================================================================

function d_hat = pam4_slice_v2014a(x, pam4_levels)

d_hat = zeros(size(x));

for k = 1:length(x)
    % Find nearest level
    distances = abs(x(k) - pam4_levels);
    [~, idx] = min(distances);
    d_hat(k) = pam4_levels(idx);
end

end
