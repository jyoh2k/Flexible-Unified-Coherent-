function PAPRdB = cal_PAPR( signal)

mean_val = mean(mean( abs(signal) .^2 ));
peak_val = max(max(abs(signal) .^2 ));
PAPRdB = pow2db(peak_val/mean_val);
end 
 