function [a_est, b_est, result] = AutoRegressive(y, x, na, nb, varargin)
% ========================================================================
% AutoRegressive: ARX (AutoRegressive with eXogenous input) Channel Estimation
%
% Usage:
%   [a, b] = AutoRegressive(y, x, na, nb)
%   [a, b, result] = AutoRegressive(y, x, na, nb)
%   [a, b, result] = AutoRegressive(y, x, na, nb, 'Method', 'SVD')
%   [a, b, result] = AutoRegressive(y, x, na, nb, 'Oversampling', 2)
%
% Parameters:
%   y           : Output signal. If 'Oversampling' is 1 (default),
%                 length(y) must equal length(x). If 'Oversampling' is L>1,
%                 y is assumed sampled at L times the rate of x (y is the
%                 oversampled signal, x is the original symbol-rate
%                 signal), so length(y) must equal length(x) * L.
%   x           : Input signal, symbol-rate (vector, length Nx).
%   na          : Number of past output taps (AR order). These taps
%                 operate at y's native sample rate -- i.e. at the
%                 oversampled rate when Oversampling = L > 1.
%                 na = 0 gives a pure FIR/MA model (no AR feedback):
%                 y[n] = b0*x[m] + b1*x[m-1] + ... + e[n].
%                 Output: a = [1, a1, a2, ..., ana] (length: na+1; just [1] if na=0)
%   nb          : Number of input taps (X order, including b0), spaced
%                 at the symbol rate (i.e. at x's native rate) regardless
%                 of Oversampling -- each symbol interval of y maps to
%                 one symbol of x.
%                 Output: b = [b0, b1, ..., b_{nb-1}] (length: nb)
%   'nk'        : Delay/dead time in units of x samples (symbols)
%                 (optional, default: 0)
%                 Positive: delay (use past inputs, causal)
%                 Negative: preview (use future inputs, non-causal)
%   'Method'    : Solution method ('LS', 'pinv', 'SVD') (default: 'LS')
%   'Window'    : Window function ('none', 'hamming', 'hanning') (default: 'none')
%   'Oversampling' : Integer L >= 1, samples of y per sample of x (default: 1).
%                 L=1: symbol-spaced model (classic ARX), x and y same rate.
%                 L>1: y is oversampled by L relative to x. Each block of L
%                 consecutive y samples shares the same aligned x (symbol)
%                 index; the AR (a) taps run at the oversampled rate of y,
%                 while the input (b) taps stay symbol-spaced on x. This
%                 models e.g. a receiver that observes an oversampled
%                 signal y generated from symbol-rate transmitted data x.
%
% Output:
%   a_est       : Estimated a coefficients [1, a1, a2, ...]
%   b_est       : Estimated b coefficients [b0, b1, ...]
%   result      : Result structure with detailed information
%                 (result.oversampling records the L used)
%
% Theory:
%   ARX Model (Oversampling=1):
%     y[n] + a1*y[n-1] + a2*y[n-2] = b0*x[n] + b1*x[n-1] + e[n]
%   Oversampled-output ARX Model (Oversampling=L):
%     Let m = floor((n-1)/L) + 1 be the symbol (x) index aligned with the
%     oversampled time step n.
%     y[n] + a1*y[n-1] + ... = b0*x[m] + b1*x[m-1] + ... + b_{nb-1}*x[m-nb+1] + e[n]
%   Regression: y = Phi*theta + e
%   Solution: theta = (Phi'*Phi)^-1*Phi'*y
% 
% Reference :
%     Golub, G.H. and Kahan, W. (1965): "Calculating the singular values and pseudo-inverse of a matrix"
%     Strang, G. (2009): "Introduction to Linear Algebra" (4th ed.), Chapter 7
%     Trefethen, L.N. and Bau, D. (1997): "Numerical Linear Algebra"
% ========================================================================

% Parse input parameters
p = inputParser;
addParamValue(p, 'nk', 0, @isnumeric);
addParamValue(p, 'Method', 'LS', @ischar);
addParamValue(p, 'Window', 'none', @ischar);
addParamValue(p, 'Oversampling', 1, @isnumeric);

parse(p, varargin{:});

nk = p.Results.nk;
method = p.Results.Method;
window = p.Results.Window;
L = p.Results.Oversampling;

% Input validation
y = y(:);
x = x(:);
Ny = length(y);
Nx = length(x);

if L < 1 || floor(L) ~= L
    error('Oversampling must be a positive integer (samples of y per sample of x).');
end

if L == 1
    if Ny ~= Nx
        error('Input and output signals must have the same length when Oversampling=1.');
    end
else
    if Ny ~= Nx * L
        error(['length(y) must equal length(x) * Oversampling (%d * %d = %d), ', ...
               'but length(y) = %d.'], Nx, L, Nx * L, Ny);
    end
end

if na < 0 || nb < 1
    error('na must be >= 0 and nb must be >= 1 (na=0 means a pure FIR/MA model with no AR feedback).');
end

% ========================================================================
% Step 1: Construct regression matrix (Phi) and output vector (Y_vec)
% ========================================================================

% n_start / n_end bound the usable oversampled y-indices (idx = 1..Ny) so
% that every y-lookback (na taps, at y's native/oversampled rate) and
% every x-tap (nb taps, symbol-spaced) stays inside the array bounds --
% including when nk < 0 (preview) pushes the x window forward past the
% end of x.
%
% For oversampled index idx, the aligned symbol (x) index is
% m(idx) = floor((idx-1)/L) + 1. x taps read m(idx) - i - nk for
% i = 0..nb-1, so:
%   min required idx: idx >= na+1  AND  idx >= L*(nb+nk-1) + 1
%   max required idx: idx <= Ny    AND  idx <= L*(Nx+nk)
n_start = max(na, L * (nb + nk - 1));
n_end   = min(Ny, L * (Nx + nk));
n_data  = n_end - n_start;

if n_data < 1
    error('Not enough data samples for the requested na, nb, nk, Oversampling.');
end

if n_data < na + nb
    warning('AutoRegressive:Underdetermined', ...
        ['n_data (%d) < na+nb (%d): regression is underdetermined, Phi''*Phi is ', ...
         'singular/rank-deficient and the solution is unreliable. Increase signal ', ...
         'length or reduce na/nb.'], n_data, na + nb);
end

Phi = zeros(n_data, na + nb);
Y_vec = zeros(n_data, 1);

% Build regression matrix
for n = 1:n_data
    idx = n_start + n;                  % oversampled (y) index
    m = floor((idx - 1) / L) + 1;       % aligned symbol (x) index

    % Past output values (negative for ARX form: y[n] + a1*y[n-1] + ...)
    % at y's native (oversampled) rate.
    for i = 1:na
        Phi(n, i) = -y(idx - i);
    end
    
    % Input values (exogenous input), symbol-spaced on x
    for i = 0:nb-1
        Phi(n, na + 1 + i) = x(m - i - nk);
    end
    
    % Output value to predict
    Y_vec(n) = y(idx);
end

% ========================================================================
% Step 2: Apply window function (optional)
% ========================================================================

w = ones(n_data, 1);
switch lower(window)
    case 'hamming'
        w = hamming(n_data);
    case 'hanning'
        w = hanning(n_data);
end

% Phi_w = diag(sqrt(w)) * Phi;
sqrt_w = sqrt(w);
% Phi_w = sqrt_w .* Phi; 
Phi_w = bsxfun(@times, sqrt_w, Phi);
Y_w = sqrt(w) .* Y_vec;

% ========================================================================
% Step 3: Solve for parameters using selected method
% ========================================================================

switch upper(method)
    case 'LS'
        % Direct least squares: theta = (Phi'*Phi)^-1*Phi'*y
        theta = (Phi_w' * Phi_w) \ (Phi_w' * Y_w);
        
    case 'PINV'
        % Pseudoinverse method: more stable
        theta = pinv(Phi_w' * Phi_w) * (Phi_w' * Y_w);
        
    case 'SVD'
        % SVD without using svd() function
        % Implement SVD using eigenvalue decomposition of Phi_w'*Phi_w
        
        [m, n] = size(Phi_w);
        
        % Compute Phi'*Phi and Phi'*y
        PhiTPhi = Phi_w' * Phi_w;
        PhiTY = Phi_w' * Y_w;
        
        % Eigenvalue decomposition: Phi'*Phi = V*Lambda*V'
        [V, Lambda] = eig(PhiTPhi);
        
        % Extract singular values (eigenvalues of Phi'*Phi)
        lambda_vals = diag(Lambda);
        
        % Sort by descending order
        [lambda_vals_sorted, idx] = sort(lambda_vals, 'descend');
        V_sorted = V(:, idx);
        
        % Compute pseudoinverse using truncation tolerance
        % Tolerance: rank-revealing threshold
        tol = max(size(Phi_w)) * eps(max(lambda_vals_sorted));
        rank_est = sum(lambda_vals_sorted > tol);
        
        % Compute theta using regularized solution
        theta = zeros(n, 1);
        for i = 1:rank_est
            if lambda_vals_sorted(i) > tol
                theta = theta + (V_sorted(:, i)' * PhiTY) / lambda_vals_sorted(i) * V_sorted(:, i);
            end
        end
        
        % Warning for ill-conditioning
        if rank_est < n
            warning('Rank deficiency detected: effective rank = %d/%d', rank_est, n);
        end
        
        cond_est = lambda_vals_sorted(1) / lambda_vals_sorted(rank_est);
        if cond_est > 1e10
            warning('High condition number: %.2e (numerical instability)', cond_est);
        end
        
    otherwise
        error('Unknown method: %s', method);
end

% ========================================================================
% Step 4: Extract estimated coefficients
% ========================================================================

a_est = [1; theta(1:na)];           % a = [1, a1, a2, ...]
b_est = theta(na+1:na+nb);          % b = [b0, b1, ...]

% ========================================================================
% Step 5: Calculate performance metrics
% ========================================================================

y_pred = Phi * theta;
dec_error = Y_vec - y_pred;
mse = mean(dec_error.^2);
rmse = sqrt(mse);
mae = mean(abs(dec_error));

y_power = mean(Y_vec.^2);
snr_residual = 10 * log10(y_power / mse);
cond_num = cond(Phi' * Phi);

% ========================================================================
% Step 6: Pole analysis and stability checks
% ========================================================================

poles = roots(a_est);
poles_mag = abs(poles);
stable = all(poles_mag < 1);

% Additional stability warnings
if cond_num > 1e10
    warning('AutoRegressive:IllConditioned', ...
        'Phi matrix condition number: %.2e (high numerical instability)', cond_num);
end

if ~stable
    % Find unstable poles
    unstable_idx = poles_mag >= 1;
    unstable_poles = poles(unstable_idx);
    unstable_mags = poles_mag(unstable_idx);
    
    warning('AutoRegressive:Unstable', ...
        'System is UNSTABLE. %d pole(s) outside unit circle:\n%s', ...
        sum(unstable_idx), mat2str(unstable_mags, 4));
end

% Pole-zero margin
if stable && length(poles) > 0
    pole_margin = min(1 - poles_mag);  % Margin from unit circle
else
    pole_margin = -inf;
end

% ========================================================================
% Step 7: Build result structure
% ========================================================================

result = struct();
result.oversampling = L;
result.theta = theta;
result.Phi = Phi;
result.Y_vec = Y_vec;
result.a_est = a_est;
result.b_est = b_est;
result.error = dec_error;
result.y_pred = y_pred;
result.mse = mse;
result.rmse = rmse;
result.mae = mae;
result.y_power = y_power;
result.snr_residual = snr_residual;
result.cond_number = cond_num;
result.poles = poles;
result.poles_mag = poles_mag;
result.stable = stable;
result.pole_margin = pole_margin;
result.n_data = n_data;
result.n_params = na + nb;

end
