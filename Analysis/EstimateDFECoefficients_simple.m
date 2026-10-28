function [w_ffe, f_fbe, result] = EstimateDFECoefficients_simple(y_rx, x_tx, N_ffe, N_fbe, varargin)
% ========================================================================
% EstimateDFECoefficients: Estimate DFE Filter Coefficients
%
% Extends AutoRegressive method to directly estimate optimal DFE coefficients
% from received signal and transmitted symbols.
%
% Usage:
%   [w_ffe, f_fbe] = EstimateDFECoefficients(y_rx, x_tx, 5, 2)
%   [w_ffe, f_fbe, result] = EstimateDFECoefficients(y_rx, x_tx, 5, 2, ...
%       'MainCursor', 3)
%
% Parameters:
%   y_rx            : Received signal at DFE input (vector, length M)
%   x_tx            : Transmitted symbols (vector, length M)
%   N_ffe           : Number of FFE taps (e.g., 5)
%   N_fbe           : Number of FBE taps (e.g., 2)
%   'MainCursor'    : FFE main cursor position (default: (N_ffe+1)/2)
%   'Method'        : Solution method ('LS', 'PINV', 'SVD') (default: 'LS')
%
% Output:
%   w_ffe           : FFE coefficients [w0, w1, ..., w_{N_ffe-1}]
%   f_fbe           : FBE coefficients [f1, f2, ..., f_{N_fbe}]
%   result          : Detailed result structure
%
% ========================================================================

% Parse input parameters
p = inputParser;
addParameter(p, 'MainCursor', [], @isnumeric);
addParameter(p, 'Method', 'LS', @ischar);

parse(p, varargin{:});

main_cursor_idx = p.Results.MainCursor;
method = p.Results.Method;

% Set default main cursor position if not specified
if isempty(main_cursor_idx)
    main_cursor_idx = (N_ffe + 1) / 2;
end

% Input validation
y_rx = y_rx(:);
x_tx = x_tx(:);
M = length(y_rx);

if length(x_tx) ~= M
    error('Received signal and transmitted symbols must have same length.');
end

if N_ffe < 1 || N_fbe < 1
    error('N_ffe and N_fbe must be >= 1.');
end

if main_cursor_idx < 1 || main_cursor_idx > N_ffe
    error('MainCursor must be between 1 and N_ffe.');
end

% ========================================================================
% Step 1: Construct regression matrix with DFE structure + MainCursor
% ========================================================================

% Maximum delay needed
% With main_cursor, FFE can look into future by (N_ffe - main_cursor_idx) samples
fir_offset = N_ffe - main_cursor_idx;  % How far into future
n_delay = max(fir_offset, N_fbe);      % Max delay considering both FFE and FBE
n_data = M - n_delay;

% Check if we have enough data
if n_data < (N_ffe + N_fbe)
    error('Not enough data for estimation. Need at least %d samples.', n_delay + N_ffe + N_fbe);
end

% Regression matrix: FFE inputs + FBE feedback
Phi = zeros(n_data, N_ffe + N_fbe);
Y_vec = zeros(n_data, 1);

% Use transmitted symbols as decision feedback (no iteration)
d = x_tx;

% Build regression matrix with main_cursor offset
for n = 1:n_data
    idx = n_delay + n;
    
    % FFE taps: y_rx at positions shifted by fir_offset
    % w[0] operates on y[n+fir_offset], w[main_cursor] operates on y[n]
    for i = 0:N_ffe-1
        tap_idx = idx + fir_offset - i;
        if tap_idx >= 1 && tap_idx <= length(y_rx)
            Phi(n, i + 1) = y_rx(tap_idx);
        else
            Phi(n, i + 1) = 0;
        end
    end
    
    % FBE taps: -d[n-1], -d[n-2], ..., -d[n-N_fbe]
    for j = 1:N_fbe
        tap_idx = idx - j;
        if tap_idx >= 1 && tap_idx <= length(d)
            Phi(n, N_ffe + j) = -d(tap_idx);
        else
            Phi(n, N_ffe + j) = 0;
        end
    end
    
    % Target: transmitted symbol at CURRENT time (always idx)
    % DFE purpose: recover x[n] using y[n+offset], y[n], y[n-past]
    target_idx = idx;                % Always current symbol
    if target_idx >= 1 && target_idx <= length(x_tx)
        Y_vec(n) = x_tx(target_idx);
    else
        Y_vec(n) = 0;
    end
end

% ========================================================================
% Step 2: Solve for parameters using selected method
% ========================================================================

switch upper(method)
    case 'LS'
        % Direct least squares
        theta = (Phi' * Phi) \ (Phi' * Y_vec);
        
    case 'PINV'
        % Pseudoinverse method
        theta = pinv(Phi' * Phi) * (Phi' * Y_vec);
        
    case 'SVD'
        % Singular value decomposition
        [U, S, V] = svd(Phi);
        theta = V * inv(S) * U' * Y_vec;
        
    otherwise
        error('Unknown method: %s', method);
end

% ========================================================================
% Step 3: Extract final coefficients
% ========================================================================

w_ffe = theta(1:N_ffe);
f_fbe = theta(N_ffe+1:N_ffe+N_fbe);

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
    snr_residual = 100;  % Very high SNR if perfect estimation
end
cond_num = cond(Phi' * Phi);

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
result.n_params = N_ffe + N_fbe;
result.main_cursor_idx = main_cursor_idx;
result.fir_offset = fir_offset;
result.n_ffe_pre = main_cursor_idx - 1;      % Taps before main cursor
result.n_ffe_post = N_ffe - main_cursor_idx; % Taps after main cursor
result.tap_description = sprintf('FFE: %d future + 1 main + %d past', fir_offset, main_cursor_idx-1);
result.N_ffe = N_ffe;
result.N_fbe = N_fbe;

end
