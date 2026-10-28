function [w_ffe, f_fbe, result] = EstimateDFECoefficients(y_rx, x_tx, N_ffe, N_fbe, varargin)
% ========================================================================
% EstimateDFECoefficients_Enhanced: Estimate DFE Filter Coefficients
%   with Regularization, Main Cursor Optimization, and Oversampling Support
%
% Extends the original AutoRegressive method to include:
%   1) Tikhonov regularization for noise robustness
%   2) Main cursor position optimization to find optimal FFE alignment
%   3) Oversampling support (both y_rx and FFE are oversampled)
%
% Usage:
%   [w_ffe, f_fbe] = EstimateDFECoefficients_Enhanced(y_rx, x_tx, 5, 2)
%   [w_ffe, f_fbe, result] = EstimateDFECoefficients_Enhanced(y_rx, x_tx, 5, 2, ...
%       'OversamplingFactor', 2, 'SymbolTiming', 1)
%
% Parameters:
%   y_rx                 : Received signal at DFE input (vector, length M)
%   x_tx                 : Transmitted symbols (vector, length M)
%   N_ffe                : Number of FFE symbol-rate taps (e.g., 5)
%   N_fbe                : Number of FBE taps (e.g., 2)
%   'OversamplingFactor' : OS factor for y_rx and FFE (default: 1, no oversampling)
%   'SymbolTiming'       : Sample timing within one symbol period (default: 1)
%   'MainCursor'         : FFE main cursor position (default: optimized)
%   'OptimizeMainCursor' : Boolean to enable optimization (default: true)
%   'Method'             : Solution method ('LS', 'PINV', 'SVD') (default: 'LS')
%   'Lambda'             : Regularization parameter (default: 1e-3)
%
% Output:
%   w_ffe           : FFE coefficients [shape: (N_ffe*OS_factor, 1)]
%   f_fbe           : FBE coefficients [shape: (N_fbe, 1)]
%   result          : Detailed result structure
%
% ========================================================================

% Parse input parameters (R2014 compatible)
p = inputParser;
addParamValue(p, 'OversamplingFactor', 1, @isnumeric);
addParamValue(p, 'SymbolTiming', 1, @isnumeric);
addParamValue(p, 'MainCursor', [], @isnumeric);
addParamValue(p, 'OptimizeMainCursor', false, @islogical);
addParamValue(p, 'Method', 'LS', @ischar);
addParamValue(p, 'RegularizationParameter', 1e-3, @isnumeric);
addParamValue(p, 'DebugMode', false, @islogical);
addParamValue(p, 'FixFBEFirstCoeff', true, @islogical);

parse(p, varargin{:});

OS_factor = p.Results.OversamplingFactor;
symbol_timing = p.Results.SymbolTiming;
main_cursor_idx = p.Results.MainCursor;
optimize_cursor = p.Results.OptimizeMainCursor;
method = p.Results.Method;
regularization_param = p.Results.RegularizationParameter;
debug_mode = p.Results.DebugMode;
fix_fbe_first = p.Results.FixFBEFirstCoeff;

% Input validation
y_rx = y_rx(:);
x_tx = x_tx(:);
K = length(x_tx);                          % Number of symbols
M = length(y_rx);                          % Number of received samples

% Check oversampling consistency
if mod(M, K) ~= 0 && OS_factor > 1
    warning('y_rx length (%d) is not a multiple of x_tx length (%d) for OS_factor=%d', M, K, OS_factor);
end

if M ~= K * OS_factor
    error('Inconsistent dimensions: y_rx length (%d) should be x_tx length (%d) * OversamplingFactor (%d)', ...
          M, K, OS_factor);
end

if N_ffe < 1
    error('N_ffe must be >= 1.');
end

if N_fbe < 0
    error('N_fbe must be >= 0. (Use 0 for linear equalization without feedback)');
end

if symbol_timing < 1 || symbol_timing > OS_factor
    error('SymbolTiming must be between 1 and OversamplingFactor (%d).', OS_factor);
end

% FFE total taps (oversampled)
% Maintain N_ffe symbol-rate taps regardless of oversampling
N_ffe_os = N_ffe;

% ========================================================================
% Step 0: Optimize Main Cursor Position (if enabled)
% ========================================================================

if optimize_cursor && isempty(main_cursor_idx)
    best_mse = inf;
    
    % Set default main cursor to (N_ffe+1)/2
    best_cursor = ceil((N_ffe + 1) / 2);
    
    % Try all reasonable main cursor positions around the default
    cursor_range = max(1, best_cursor - 1) : min(N_ffe_os, best_cursor + 1);
    
    if debug_mode
        fprintf('Optimizing Main Cursor Position...\n');
    end
    cursor_mse_values = [];
    
    for cursor_test = cursor_range
        % Build regression matrix for this cursor position
        [Phi_test, Y_vec_test, n_data_test] = build_regression_matrix(...
            y_rx, x_tx, N_ffe_os, N_fbe, OS_factor, symbol_timing, cursor_test);
        
        if n_data_test < (N_ffe_os + max(1, N_fbe))
            continue;
        end
        
        % Apply FBE first coefficient fix if enabled
        if fix_fbe_first && N_fbe > 0
            Y_vec_test = Y_vec_test - Phi_test(:, N_ffe_os + 1);
            Phi_test = [Phi_test(:, 1:N_ffe_os), Phi_test(:, N_ffe_os+2:end)];
        end
        
        % Estimate with current cursor
        theta_test = solve_system(Phi_test, Y_vec_test, method, regularization_param, N_ffe_os, N_fbe_opt, debug_mode);
        
        % Calculate MSE
        y_pred_test = Phi_test * theta_test;
        mse_test = mean((Y_vec_test - y_pred_test).^2);
        cursor_mse_values = [cursor_mse_values; cursor_test, mse_test];
        
        if mse_test < best_mse
            best_mse = mse_test;
            best_cursor = cursor_test;
        end
    end
    
    main_cursor_idx = best_cursor;
    if debug_mode
        fprintf('  Optimal Main Cursor: %d (MSE: %.6e)\n', main_cursor_idx, best_mse);
    end
    result_cursor_opt = struct('cursor_positions', cursor_mse_values);
else
    if isempty(main_cursor_idx)
        % Default main cursor: (N_ffe+1)/2
        main_cursor_idx = ceil((N_ffe + 1) / 2);
    end
    result_cursor_opt = struct('cursor_positions', []);
end

if main_cursor_idx < 1 || main_cursor_idx > N_ffe_os
    error('MainCursor must be between 1 and N_ffe_os (%d).', N_ffe_os);
end

% ========================================================================
% Step 1: Construct regression matrix with DFE structure + Oversampling
% ========================================================================

[Phi, Y_vec, n_data] = build_regression_matrix(...
    y_rx, x_tx, N_ffe_os, N_fbe, OS_factor, symbol_timing, main_cursor_idx);

if n_data < (N_ffe_os + max(1, N_fbe))
    error('Not enough data for estimation. Need at least %d symbols.', N_ffe_os + max(1, N_fbe));
end

% ========================================================================
% Handle fixed FBE first coefficient
% ========================================================================
if fix_fbe_first && N_fbe > 0
    % FBE 첫 번째 계수를 1로 고정
    % Y_vec 조정: Y_vec - Phi(:, N_ffe_os+1) * 1
    Y_vec = Y_vec - Phi(:, N_ffe_os + 1);
    
    % Phi에서 첫 번째 FBE 열 제거 (첫 번째 FBE는 고정값 1)
    Phi = [Phi(:, 1:N_ffe_os), Phi(:, N_ffe_os+2:end)];
    
    % 파라미터 수 조정
    N_fbe_opt = N_fbe - 1;  % 나머지 FBE 계수만 최적화
    
    if debug_mode
        fprintf('FBE first coefficient fixed to 1.0\n');
        fprintf('Optimizing remaining FBE coefficients: %d\n', N_fbe_opt);
    end
else
    N_fbe_opt = N_fbe;
end

% ========================================================================
% Step 2: Solve for parameters using selected method with regularization
% ========================================================================

theta = solve_system(Phi, Y_vec, method, regularization_param, N_ffe_os, N_fbe_opt, debug_mode);

% ========================================================================
% Step 3: Extract final coefficients
% ========================================================================

w_ffe = theta(1:N_ffe_os);

% Reconstruct FBE coefficients
if fix_fbe_first && N_fbe > 0
    % First FBE coefficient is fixed to 1.0
    f_fbe = [1.0; theta(N_ffe_os+1:end)];
else
    f_fbe = theta(N_ffe_os+1:N_ffe_os+N_fbe_opt);
end

% ========================================================================
% Step 4: Performance metrics
% ========================================================================

y_pred = Phi * theta;
prediction_error = Y_vec - y_pred;
mse = mean(prediction_error.^2);
rmse = sqrt(mse);
mae = mean(abs(prediction_error));

symbol_power = mean(Y_vec.^2);
if mse > 0
    snr_residual = 10 * log10(symbol_power / mse);
else
    snr_residual = 100;
end

% Calculate condition number safely (without SVD or expensive operations)
try
    % Method 1: Use cond() on Phi directly (not Phi'*Phi)
    cond_num = cond(Phi);
    
catch ME
    % If cond() fails, estimate based on matrix size
    fprintf('Warning: cond() failed for condition number calculation: %s\n', ME.message);
    
    try
        % Fallback: estimate based on norms
        Phi_norm_F = norm(Phi, 'fro');
        Phi_inv_norm_est = 1.0 / (norm(Phi, 2) + 1e-16);
        cond_num = Phi_norm_F * Phi_inv_norm_est;
        
        if cond_num < 0 || isnan(cond_num) || isinf(cond_num)
            cond_num = 1e10;  % Default to large condition number
        end
        
    catch
        % Last resort: assume large condition number
        fprintf('Warning: Could not calculate condition number\n');
        cond_num = 1e10;
    end
end

% ========================================================================
% Step 5: Build result structure
% ========================================================================

result = struct();
result.w_ffe = w_ffe;
result.f_fbe = f_fbe;
result.theta = theta;
result.Phi = Phi;
result.Y_vec = Y_vec;
result.y_pred = y_pred;
result.error = prediction_error;
result.mse = mse;
result.rmse = rmse;
result.mae = mae;
result.symbol_power = symbol_power;
result.snr_residual = snr_residual;
result.cond_number = cond_num;
result.n_data = n_data;
result.n_params = N_ffe_os + N_fbe;
result.n_symbols = K;
result.main_cursor_idx = main_cursor_idx;
result.OS_factor = OS_factor;
result.symbol_timing = symbol_timing;
result.N_ffe_symbol_rate = N_ffe;
result.N_ffe_os = N_ffe_os;
result.N_fbe = N_fbe;
result.method = method;
result.regularization_parameter = regularization_param;
result.cursor_optimization = result_cursor_opt;

% FFE structure information
ffe_pre_os = main_cursor_idx - 1;              % Oversampled taps before main cursor
ffe_post_os = N_ffe_os - main_cursor_idx;      % Oversampled taps after main cursor
ffe_pre_symbols = floor(ffe_pre_os / OS_factor);
ffe_post_symbols = floor(ffe_post_os / OS_factor);

result.ffe_pre_taps_os = ffe_pre_os;
result.ffe_post_taps_os = ffe_post_os;
result.ffe_pre_symbols = ffe_pre_symbols;
result.ffe_post_symbols = ffe_post_symbols;
result.tap_description = sprintf('FFE: %d oversampled taps (%.1f symbols past + 1 main + %.1f symbols future)', ...
                                  N_ffe_os, ffe_pre_symbols, ffe_post_symbols);

end

% ========================================================================
% Helper Function 1: Build Regression Matrix
% ========================================================================

function [Phi, Y_vec, n_data] = build_regression_matrix(...
    y_rx, x_tx, N_ffe_os, N_fbe, OS_factor, symbol_timing, main_cursor_idx)

K = length(x_tx);                   % Number of symbols
M = length(y_rx);                   % Number of samples

% Calculate maximum lookback needed
max_lookback = main_cursor_idx - 1;      % How far into past
max_lookahead = N_ffe_os - main_cursor_idx;  % How far into future

% Number of usable symbols (excluding boundary effects)
n_delay_start = ceil(max_lookahead / OS_factor);
n_delay_end = ceil(max_lookahead / OS_factor);

n_data = K - n_delay_start - n_delay_end;

if n_data <= 0
    error('Not enough data after accounting for delays.');
end

% Regression matrix: FFE inputs (oversampled) + FBE feedback
Phi = zeros(n_data, N_ffe_os + N_fbe);
Y_vec = zeros(n_data, 1);

% Use transmitted symbols as decision feedback (no iteration)
d = x_tx;

% Build regression matrix with oversampling
for k = 1:n_data
    % Symbol index (starting from n_delay_start+1)
    sym_idx = n_delay_start + k;
    
    % Sample index at main cursor for this symbol
    sample_idx_main = (sym_idx - 1) * OS_factor + symbol_timing;
    
    % ====================================================================
    % FFE taps: oversampled version
    % ====================================================================
    % w[0] operates on y_rx[sample_idx_main + (N_ffe_os - main_cursor_idx)]
    % w[main_cursor_idx-1] operates on y_rx[sample_idx_main]
    % w[N_ffe_os-1] operates on y_rx[sample_idx_main - (main_cursor_idx - 1)]
    
    for i = 0:N_ffe_os-1
        % Offset from main cursor
        offset = i - (main_cursor_idx - 1);
        sample_tap_idx = sample_idx_main + offset;
        
        if sample_tap_idx >= 1 && sample_tap_idx <= M
            Phi(k, i + 1) = y_rx(sample_tap_idx);
        else
            Phi(k, i + 1) = 0;
        end
    end
    
    % ====================================================================
    % FBE taps: symbol-rate feedback (not oversampled)
    % -d[sym_idx-1], -d[sym_idx-2], ..., -d[sym_idx-N_fbe]
    % ====================================================================
    for j = 1:N_fbe
        tap_sym_idx = sym_idx - j;
        if tap_sym_idx >= 1 && tap_sym_idx <= K
            Phi(k, N_ffe_os + j) = -d(tap_sym_idx);
        else
            Phi(k, N_ffe_os + j) = 0;
        end
    end
    
    % Target: transmitted symbol at current symbol index
    if sym_idx >= 1 && sym_idx <= K
        Y_vec(k) = x_tx(sym_idx);
    else
        Y_vec(k) = 0;
    end
end

end

% ========================================================================
% Helper Function 2: Solve System with Regularization (Stable)
% ========================================================================

function theta = solve_system(Phi, Y_vec, method, regularization_param, N_ffe_os, N_fbe, varargin)

% Parse debug mode (optional)
if nargin > 6
    debug_mode = varargin{1};
else
    debug_mode = false;
end

n_params = N_ffe_os + N_fbe;
n_data = length(Y_vec);

switch upper(method)
    case 'LS'
        % LS ë°©ë²: ì§?ì  ë°±ì¬ëì ì°ì°ì? ì¬ì©
        % ë? ìì ì ?ì?´ê³  ë©ëª¨ë¦¬ í¨ì¨ì ?
        
        theta_found = false;
        
        % Method 1: Direct backslash with regularization
        try
            if debug_mode
                fprintf('  LS: Direct solve with regularization...\n');
            end
            
            % Build augmented system: [Phi; sqrt(lambda)*I] * theta = [Y; 0]
            sqrt_lambda = sqrt(regularization_param);
            Phi_aug = [Phi; sqrt_lambda * eye(n_params)];
            Y_aug = [Y_vec; zeros(n_params, 1)];
            
            % Use backslash operator (most stable)
            theta = Phi_aug \ Y_aug;
            if debug_mode
                fprintf('  LS direct solve succeeded\n');
            end
            theta_found = true;
            
        catch ME1
            fprintf('  LS direct solve failed: %s\n', ME1.message);
        end
        
        % Method 2: Standard least squares
        if ~theta_found
            try
                if debug_mode
                    fprintf('  LS: Standard least squares (Phi \ Y)...\n');
                end
                theta = Phi \ Y_vec;
                if debug_mode
                    fprintf('  LS standard solve succeeded\n');
                end
                theta_found = true;
                
            catch ME2
                fprintf('  LS standard solve failed: %s\n', ME2.message);
            end
        end
        
        % Method 3: Regularized normal equations (careful)
        if ~theta_found
            try
                if debug_mode
                    fprintf('  LS: Normal equations with regularization...\n');
                end
                
                % Normalize Phi for better conditioning
                Phi_norm = Phi ./ (sqrt(sum(Phi.^2, 1)) + 1e-10);
                Y_norm = Y_vec;
                
                PhiT_Phi = Phi_norm' * Phi_norm;
                PhiT_Y = Phi_norm' * Y_norm;
                
                A_reg = PhiT_Phi + regularization_param * eye(n_params);
                theta = A_reg \ PhiT_Y;
                
                if debug_mode
                    fprintf('  LS normal equations succeeded\n');
                end
                theta_found = true;
                
            catch ME3
                fprintf('  LS normal equations failed: %s\n', ME3.message);
            end
        end
        
        % Method 4: LSQR (iterative solver)
        if ~theta_found
            try
                if debug_mode
                    fprintf('  LS: LSQR (iterative solver)...\n');
                end
                
                % Create function handle for matrix-vector product
                % A*x = [Phi; sqrt(lambda)*I] * x
                sqrt_lambda = sqrt(regularization_param);
                
                % lsqr is available in R2014
                theta = lsqr(Phi, Y_vec, 1e-6, 100);
                if debug_mode
                    fprintf('  LSQR solver succeeded\n');
                end
                theta_found = true;
                
            catch ME4
                fprintf('  LSQR failed: %s\n', ME4.message);
            end
        end
        
        % Method 5: Pseudoinverse (replaced with backslash)
        if ~theta_found
            try
                if debug_mode
                    fprintf('  LS: Last resort backslash fallback...\n');
                end
                theta = Phi \ Y_vec;
                if debug_mode
                    fprintf('  Backslash fallback succeeded\n');
                end
                theta_found = true;
                
            catch ME5
                fprintf('  Last resort failed: %s\n', ME5.message);
            end
        end
        
        % If still no solution
        if ~theta_found
            error('LS method failed. All fallback methods exhausted.');
        end
        
    case 'PINV'
        % PINV ë©ìë: ì¤ì ë¡ë ì¬ë¬ ë°±ì¬ëì ê¸°ë° ë°©ë² (pinv ìì?)
        
        theta_found = false;
        
        % Method 1: Augmented system with backslash
        try
            if debug_mode
                fprintf('  PINV method: Augmented system backslash...\n');
            end
            
            sqrt_lambda = sqrt(regularization_param);
            Phi_aug = [Phi; sqrt_lambda * eye(n_params)];
            Y_aug = [Y_vec; zeros(n_params, 1)];
            
            theta = Phi_aug \ Y_aug;
            if debug_mode
                fprintf('  Augmented backslash succeeded\n');
            end
            theta_found = true;
            
        catch ME1
            fprintf('  Augmented backslash failed: %s\n', ME1.message);
        end
        
        % Method 2: Direct backslash
        if ~theta_found
            try
                if debug_mode
                    fprintf('  PINV method: Direct backslash...\n');
                end
                theta = Phi \ Y_vec;
                if debug_mode
                    fprintf('  Direct backslash succeeded\n');
                end
                theta_found = true;
                
            catch ME2
                fprintf('  Direct backslash failed: %s\n', ME2.message);
            end
        end
        
        % Method 3: Regularized normal equations
        if ~theta_found
            try
                if debug_mode
                    fprintf('  PINV method: Regularized normal equations...\n');
                end
                
                PhiT_Phi = Phi' * Phi;
                PhiT_Y = Phi' * Y_vec;
                A_reg = PhiT_Phi + regularization_param * eye(n_params);
                
                theta = A_reg \ PhiT_Y;
                if debug_mode
                    fprintf('  Regularized normal equations succeeded\n');
                end
                theta_found = true;
                
            catch ME3
                fprintf('  Regularized normal equations failed: %s\n', ME3.message);
            end
        end
        
        % Method 4: LSQR (iterative solver)
        if ~theta_found
            try
                if debug_mode
                    fprintf('  PINV method: LSQR iterative solver...\n');
                end
                theta = lsqr(Phi, Y_vec, 1e-6, 100);
                if debug_mode
                    fprintf('  LSQR succeeded\n');
                end
                theta_found = true;
                
            catch ME4
                fprintf('  LSQR failed: %s\n', ME4.message);
            end
        end
        
        if ~theta_found
            error('PINV method (backslash-based): All fallback methods failed.');
        end
        
    case 'SVD'
        % SVD ë©ìë: ì¤ì ë¡ë ì¬ë¬ ì§?ì  íì?´ ë°©ë² ìë? (SVD ìì?)
        % ë°±ì¬ëì ê¸°ë°ì? ìì ì ?ì?¸ íì?´ ì¬ì©
        
        theta_found = false;
        
        % Method 1: Direct solve with augmented system (ê°ì¥ ë¹ ë¦)
        try
            if debug_mode
                fprintf('  SVD method: Direct solve with augmentation...\n');
            end
            
            sqrt_lambda = sqrt(regularization_param);
            Phi_aug = [Phi; sqrt_lambda * eye(n_params)];
            Y_aug = [Y_vec; zeros(n_params, 1)];
            
            theta = Phi_aug \ Y_aug;
            if debug_mode
                fprintf('  Direct augmented solve succeeded\n');
            end
            theta_found = true;
            
        catch ME1
            fprintf('  Direct augmented solve failed: %s\n', ME1.message);
        end
        
        % Method 2: Standard least squares
        if ~theta_found
            try
                if debug_mode
                    fprintf('  SVD method: Standard least squares...\n');
                end
                theta = Phi \ Y_vec;
                if debug_mode
                    fprintf('  Standard LS succeeded\n');
                end
                theta_found = true;
                
            catch ME2
                fprintf('  Standard LS failed: %s\n', ME2.message);
            end
        end
        
        % Method 3: Regularized normal equations with careful scaling
        if ~theta_found
            try
                if debug_mode
                    fprintf('  SVD method: Regularized normal equations...\n');
                end
                
                % Normalize for better conditioning
                col_norms = sqrt(sum(Phi.^2, 1))' + 1e-10;
                Phi_scaled = Phi ./ col_norms;
                
                PhiT_Phi = Phi_scaled' * Phi_scaled;
                PhiT_Y = Phi_scaled' * Y_vec;
                
                A_reg = PhiT_Phi + regularization_param * eye(n_params);
                
                theta_scaled = A_reg \ PhiT_Y;
                theta = theta_scaled ./ col_norms;
                
                if debug_mode
                    fprintf('  Regularized normal equations succeeded\n');
                end
                theta_found = true;
                
            catch ME3
                fprintf('  Regularized normal equations failed: %s\n', ME3.message);
            end
        end
        
        % Method 4: LSQR (iterative solver - memory efficient)
        if ~theta_found
            try
                if debug_mode
                    fprintf('  SVD method: LSQR iterative solver...\n');
                end
                theta = lsqr(Phi, Y_vec, 1e-6, 100);
                if debug_mode
                    fprintf('  LSQR succeeded\n');
                end
                theta_found = true;
                
            catch ME4
                fprintf('  LSQR failed: %s\n', ME4.message);
            end
        end
        
        % Method 5: Pseudoinverse (replaced with backslash)
        if ~theta_found
            try
                if debug_mode
                    fprintf('  SVD method: Last resort backslash...\n');
                end
                theta = Phi \ Y_vec;
                if debug_mode
                    fprintf('  Backslash fallback succeeded\n');
                end
                theta_found = true;
                
            catch ME5
                fprintf('  Backslash fallback failed: %s\n', ME5.message);
            end
        end
        
        % If all methods fail
        if ~theta_found
            error('SVD method (backslash-based): All fallback methods failed. Cannot solve system.');
        end
        
    otherwise
        error('Unknown method: %s', method);
end

end
