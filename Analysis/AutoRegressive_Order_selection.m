function [na_opt, nb_opt, info] = order_selection(y, x, na_max, nb_max, varargin)
% ========================================================================
% ORDER_SELECTION: Automatic (na, nb) order selection for AutoRegressive.m
%
% Usage:
%   [na_opt, nb_opt, info] = order_selection(y, x, na_max, nb_max)
%   [na_opt, nb_opt, info] = order_selection(y, x, na_max, nb_max, 'Criterion', 'BIC')
%   [na_opt, nb_opt, info] = order_selection(y, x, na_max, nb_max, ...
%                                             'nk', 1, 'Oversampling', 2)
%
% Sweeps na = 0:na_max (na=0 = pure FIR/MA, no AR feedback), nb = 1:nb_max,
% fits AutoRegressive for each
% combination, and scores each combination with a model-order criterion:
%
%   'AIC' (default) : N*log(mse) + 2*k              (k = na+nb)
%   'BIC'           : N*log(mse) + k*log(N)          (penalizes complexity harder)
%   'CV'            : k-fold blocked cross-validation RMSE, averaged over
%                     folds (splits the regression rows -- res.Phi/res.Y_vec
%                     from AutoRegressive -- into contiguous blocks; each
%                     fold holds one block out for validation and fits on
%                     the rest, then RMSE is averaged across folds). Reuses
%                     AutoRegressive's own Phi/Y_vec so the Oversampling/nk
%                     logic is not duplicated here.
%
% Parameters (name-value pairs):
%   'nk'           : passed through to AutoRegressive (default 0)
%   'Oversampling' : passed through to AutoRegressive (default 1)
%   'Method'       : passed through to AutoRegressive (default 'LS')
%   'Window'       : passed through to AutoRegressive (default 'none')
%   'Criterion'    : 'AIC' | 'BIC' | 'CV' (default 'AIC')
%   'CVFolds'      : number of blocked folds for CV (default 5)
%   'Verbose'      : true/false, print a results table (default true)
%
% Output:
%   na_opt, nb_opt : orders that minimize the chosen criterion
%   info           : struct with fields
%       .na_list, .nb_list   : grids of orders tried (0:na_max, 1:nb_max)
%       .aic, .bic           : ((na_max+1) x nb_max) matrices of criterion values
%       .cv_rmse             : ((na_max+1) x nb_max) matrix of CV RMSE (NaN if not computed)
%       .mse                 : ((na_max+1) x nb_max) matrix of training MSE
%       .criterion           : criterion string used for selection
%       .best_value          : criterion value at (na_opt, nb_opt)
%
% Note on 'AIC'/'BIC' vs 'CV':
%   AIC/BIC are fast (single fit per order) and standard for ARX order
%   selection, but assume the noise model is roughly Gaussian/white.
%   CV directly measures out-of-sample prediction error and makes no
%   distributional assumption, at the cost of holding out data. For a
%   final answer, it's reasonable to check that AIC, BIC and CV agree.
%
% MATLAB 2014a compatible (plain function file, fprintf only).
% ========================================================================

p = inputParser;
addParamValue(p, 'nk', 0, @isnumeric);
addParamValue(p, 'Oversampling', 1, @isnumeric);
addParamValue(p, 'Method', 'LS', @ischar);
addParamValue(p, 'Window', 'none', @ischar);
addParamValue(p, 'Criterion', 'AIC', @ischar);
addParamValue(p, 'CVFolds', 5, @isnumeric);
addParamValue(p, 'Verbose', true, @islogical);

parse(p, varargin{:});

nk_       = p.Results.nk;
L_        = p.Results.Oversampling;
method_   = p.Results.Method;
window_   = p.Results.Window;
criterion = upper(p.Results.Criterion);
cv_folds  = p.Results.CVFolds;
verbose   = p.Results.Verbose;

na_list = 0:na_max;
nb_list = 1:nb_max;

n_na = length(na_list);
aic     = NaN(n_na, nb_max);
bic     = NaN(n_na, nb_max);
mse_mat = NaN(n_na, nb_max);
cv_rmse = NaN(n_na, nb_max);

for ia = 1:n_na
    na_ = na_list(ia);
    for ib = 1:nb_max
        nb_ = nb_list(ib);
        try
            [~, ~, res] = AutoRegressive(y, x, na_, nb_, ...
                'nk', nk_, 'Oversampling', L_, 'Method', method_, 'Window', window_);

            k = na_ + nb_;
            Nfit = res.n_data;
            mse_train = res.mse;
            mse_mat(ia, ib) = mse_train;

            if mse_train > 0 && Nfit > k
                aic(ia, ib) = Nfit * log(mse_train) + 2 * k;
                bic(ia, ib) = Nfit * log(mse_train) + k * log(Nfit);
            end

            if strcmp(criterion, 'CV')
                Phi_full = res.Phi;
                Y_full   = res.Y_vec;
                n_rows   = size(Phi_full, 1);
                nf       = min(cv_folds, n_rows);  % can't have more folds than rows

                if nf >= 2
                    edges = round(linspace(0, n_rows, nf + 1));  % fold boundaries
                    fold_rmse = NaN(nf, 1);
                    for f = 1:nf
                        val_idx = (edges(f)+1):edges(f+1);
                        tr_idx  = setdiff(1:n_rows, val_idx);

                        if length(tr_idx) >= k && ~isempty(val_idx)
                            Phi_tr = Phi_full(tr_idx, :);
                            Y_tr   = Y_full(tr_idx);
                            Phi_va = Phi_full(val_idx, :);
                            Y_va   = Y_full(val_idx);

                            theta_tr = pinv(Phi_tr' * Phi_tr) * (Phi_tr' * Y_tr);
                            resid_va = Y_va - Phi_va * theta_tr;
                            fold_rmse(f) = sqrt(mean(resid_va.^2));
                        end
                    end
                    if any(isfinite(fold_rmse))
                        cv_rmse(ia, ib) = mean(fold_rmse(isfinite(fold_rmse)));
                    end
                end
            end
        catch
            % Infeasible order (e.g. not enough data) -> leave as NaN
        end
    end
end

switch criterion
    case 'AIC'
        score = aic;
    case 'BIC'
        score = bic;
    case 'CV'
        score = cv_rmse;
    otherwise
        error('Unknown Criterion: %s (use ''AIC'', ''BIC'', or ''CV'')', criterion);
end

[best_value, lin_idx] = min(score(:));
if ~isfinite(best_value)
    error('order_selection: no feasible (na, nb) combination found in the given ranges.');
end
[ia_opt, ib_opt] = ind2sub(size(score), lin_idx);
na_opt = na_list(ia_opt);
nb_opt = nb_list(ib_opt);

info = struct();
info.na_list = na_list;
info.nb_list = nb_list;
info.aic = aic;
info.bic = bic;
info.cv_rmse = cv_rmse;
info.mse = mse_mat;
info.criterion = criterion;
info.best_value = best_value;

if verbose
    fprintf('Order selection (criterion = %s), searching na=0:%d, nb=1:%d\n', criterion, na_max, nb_max);
    fprintf('%6s %6s %12s %12s %12s %12s\n', 'na', 'nb', 'MSE', 'AIC', 'BIC', 'CV RMSE');
    for ia = 1:n_na
        for ib = 1:nb_max
            marker = ' ';
            if ia == ia_opt && ib == ib_opt
                marker = '*';
            end
            fprintf('%6d %6d %12.4g %12.4g %12.4g %12.4g %s\n', ...
                na_list(ia), nb_list(ib), mse_mat(ia, ib), aic(ia, ib), bic(ia, ib), cv_rmse(ia, ib), marker);
        end
    end
    fprintf('--> Selected: na=%d, nb=%d (%s = %.6g)\n', na_opt, nb_opt, criterion, best_value);
end

end
