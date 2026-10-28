function [a_est, b_est, result] = AutoRegressiveMulti(y_cell, x_cell, na, nb, varargin)
% ========================================================================
% AUTOREGRESSIVEMULTI: Combine multiple repeated measurements to jointly
% estimate one shared ARX channel (a, b).
%
% Instead of fitting each measurement separately and averaging the
% resulting coefficients, this stacks every measurement's regression
% equations (built by AutoRegressive.m's own Phi/Y_vec construction, so
% nk/Oversampling/boundary handling is not duplicated here) into one
% larger least-squares problem and solves it once.
%
% Usage:
%   [a_est, b_est, result] = AutoRegressiveMulti(y_cell, x_cell, na, nb)
%   [a_est, b_est, result] = AutoRegressiveMulti(y_cell, x_cell, na, nb, 'Method', 'SVD')
%   [a_est, b_est, result] = AutoRegressiveMulti(y_cell, x_cell, na, nb, 'nk', 1, 'Oversampling', 2)
%
% Parameters:
%   y_cell, x_cell : 1xM or Mx1 cell arrays. y_cell{k}, x_cell{k} is the
%                    k-th repeated measurement pair -- assumed generated
%                    by the SAME underlying channel (a, b) but with
%                    independent noise/measurement error each time (e.g.
%                    M repeated optical back-to-back captures).
%   na, nb         : same meaning as AutoRegressive.m.
%   'nk'           : passed through to each measurement's regression
%                    construction (default 0). Same value used for all
%                    measurements -- the physical setup is assumed fixed.
%   'Oversampling' : passed through, same for all measurements (default 1).
%   'Window'       : passed through, applied per-measurement before
%                    stacking (default 'none').
%   'Method'       : 'LS' | 'pinv' | 'SVD', used once on the STACKED
%                    regression problem (default 'LS').
%
% Output:
%   a_est, b_est : channel estimate from the combined (stacked) fit.
%   result       : struct with the same fields as AutoRegressive.m's
%                  result (mse, rmse, poles, stable, cond_number, ...),
%                  computed on the combined data, plus:
%       result.M                : number of measurements combined
%       result.n_data_per_meas  : regression rows contributed by each
%                                 measurement (vector, length M)
%       result.n_data_total     : total combined regression rows
%
% Why stack instead of average per-measurement estimates?
%   Averaging M separately-fitted (a,b) only helps if each individual fit
%   is already reasonably well-conditioned; if any single measurement is
%   short/noisy, its estimate can be poor or unstable, and a naive average
%   still carries that damage. Stacking the raw regression rows first and
%   solving once is equivalent to fitting on one M-times-longer combined
%   measurement: it pools information before fitting, directly improves
%   the conditioning of Phi'*Phi (M times more rows), and is the
%   statistically efficient combination under i.i.d. measurement noise.
%
% MATLAB 2014a compatible (plain function file, fprintf/cell2mat only).
% ========================================================================

p = inputParser;
addParamValue(p, 'nk', 0, @isnumeric);
addParamValue(p, 'Oversampling', 1, @isnumeric);
addParamValue(p, 'Method', 'LS', @ischar);
addParamValue(p, 'Window', 'none', @ischar);
parse(p, varargin{:});

nk_ = p.Results.nk;
L_ = p.Results.Oversampling;
method_ = p.Results.Method;
window_ = p.Results.Window;

M = length(y_cell);
if length(x_cell) ~= M
    error('y_cell and x_cell must have the same number of measurements.');
end
if M < 1
    error('At least one measurement is required.');
end

Phi_list = cell(M, 1);
Y_list = cell(M, 1);
n_data_per_meas = zeros(M, 1);

for k = 1:M
    % Reuse AutoRegressive.m's own regression-matrix construction (it
    % already handles nk / Oversampling / boundary trimming correctly);
    % the 'Method' used here doesn't matter since we discard a_est/b_est
    % and only keep the raw (unweighted) Phi/Y_vec for stacking.
    [~, ~, res_k] = AutoRegressive(y_cell{k}, x_cell{k}, na, nb, ...
        'nk', nk_, 'Oversampling', L_, 'Method', 'LS', 'Window', window_);
    Phi_list{k} = res_k.Phi;
    Y_list{k} = res_k.Y_vec;
    n_data_per_meas(k) = res_k.n_data;
end

Phi_all = cell2mat(Phi_list);
Y_all = cell2mat(Y_list);

n_data_total = size(Phi_all, 1);
k_params = na + nb;

if n_data_total < k_params
    warning('AutoRegressiveMulti:Underdetermined', ...
        ['combined n_data (%d) < na+nb (%d): still underdetermined even ', ...
         'after combining %d measurements.'], n_data_total, k_params, M);
end

switch upper(method_)
    case 'LS'
        theta = (Phi_all' * Phi_all) \ (Phi_all' * Y_all);

    case 'PINV'
        theta = pinv(Phi_all' * Phi_all) * (Phi_all' * Y_all);

    case 'SVD'
        PhiTPhi = Phi_all' * Phi_all;
        PhiTY = Phi_all' * Y_all;

        [V, Lambda] = eig(PhiTPhi);
        lambda_vals = diag(Lambda);
        [lambda_sorted, idx] = sort(lambda_vals, 'descend');
        V_sorted = V(:, idx);

        tol = max(size(Phi_all)) * eps(max(lambda_sorted));
        rank_est = sum(lambda_sorted > tol);

        n_theta = size(Phi_all, 2);
        theta = zeros(n_theta, 1);
        for i = 1:rank_est
            theta = theta + (V_sorted(:, i)' * PhiTY) / lambda_sorted(i) * V_sorted(:, i);
        end

        if rank_est < n_theta
            warning('AutoRegressiveMulti:RankDeficient', ...
                'Rank deficiency detected: effective rank = %d/%d', rank_est, n_theta);
        end

    otherwise
        error('Unknown method: %s', method_);
end

a_est = [1; theta(1:na)];
b_est = theta(na+1:na+nb);

y_pred = Phi_all * theta;
dec_error = Y_all - y_pred;
mse = mean(dec_error.^2);
rmse = sqrt(mse);
mae = mean(abs(dec_error));

y_power = mean(Y_all.^2);
snr_residual = 10 * log10(y_power / mse);
cond_num = cond(Phi_all' * Phi_all);

poles = roots(a_est);
poles_mag = abs(poles);
stable = all(poles_mag < 1);

result = struct();
result.M = M;
result.n_data_per_meas = n_data_per_meas;
result.n_data_total = n_data_total;
result.oversampling = L_;
result.theta = theta;
result.Phi = Phi_all;
result.Y_vec = Y_all;
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
result.n_params = k_params;

end
