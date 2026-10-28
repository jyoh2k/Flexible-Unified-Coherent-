
function [params, skewout]     = SkewEstimator( in, params )

    if (params.skew.en_est == 0 ) 
        skewout.sft=0;
        return
    end
         
    for idim=1:size(in,1)
        [tau_init(2*idim-1,:), phase_errori]= TPR_init(real(in(idim,:)), real(in(idim,:)), params.tpr, ''); 
        [tau_init(2*idim,:), phase_errorq]= TPR_init(imag(in(idim,:)), real(in(idim,:)),  params.tpr, ''); 
        skewout1(idim, :) = phase_errori +1j*phase_errorq;
    end
    tau_skew =tau_init(1)- tau_init';
%     tau_skew = - tau_init';
%     tau_skew(1:2) = tau_skew(1:2) + 0.5;
    tau_skew = mod(tau_skew +  params.tpr.OV/2,  params.tpr.OV)- params.tpr.OV/2;
     for idim=1:size(in,1)
         out(idim) = tau_skew(idim*2-1) + 1j*tau_skew(idim*2);
     end 
     
     if ( params.skew.en == 1 ) 
         params.skew.sft = out;
     end 
     skewout.out = skewout1;     
     ps =1e-12;
     skewout.sft = out /params.RXSampleFreq/ps;
end

function [tau_init , phase_error]= TPR_init(AIN1, training, params, T)
   STEP =64;
    iSa = 1; idx=1;
    for tau_int =0:1
        for tau_frac=0:1/STEP:(1 -1/STEP)
            SIdx = ( iSa :( iSa+params.PRL + (params.L * 2 - 1)) ) + tau_int ;
             [AOUT_tmp] = TPR( real(AIN1(1,SIdx)), tau_frac, params, T);
             phase_error(idx) = TPE( AOUT_tmp, training, params, T ) ; 
             idx=idx+1;
        end
    end
    tau_list = 0:1/STEP:(2 -1/STEP);
    [val, pos] = min(abs(phase_error));
    phase_error_sft = phase_error - [phase_error(2:end) phase_error(1)];
    [val, pos] = max(abs(phase_error_sft));
    tau_init = tau_list(pos);
end
