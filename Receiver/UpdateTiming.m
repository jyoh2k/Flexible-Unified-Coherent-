
function  [ tau_delay2, align_offset ] = UpdateTiming( tau, T )
    align_offset  = round(floor(tau(1)));
%    align_offset  = round((tau(1)));
    tau_delay2    = tau(1) - align_offset ;
end
