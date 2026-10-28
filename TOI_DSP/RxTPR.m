function [AOUT, tprout] = RxTPR( AIN, training, params )  

%  Usage      :  AOUT = RxTPR( AIN, training, params )   
%
%  Function   :
%     Timing phase recovery block ( Feedback time only)
%
%  Port  :
%     1. AIN        : Original signal
%     2. params     : TPR parameter
%     3.   T        : Reserved for fixed sim.
%     4. AOUT       : Resampled signal
%     5. tprout     : Recovered timing error (For debugging use)
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
        
    %%  Initial value 
    [d1, d2] = size( AIN);
    PRL         =  params.PRL; 
    global FIXED_ARCHITECTURE
    if  ( FIXED_ARCHITECTURE == 1 )
      DLY         = 16;
    else
      DLY         = 0;
    end
    tau         = ones(1, d2 + 1 + DLY*PRL ) * params.tau_init;
    acc_error   = zeros(1, d2 + 1) ;
    phase_error = zeros(1, d2 + 1) ;
    T              = params.T;
    zeropad     = ceil(d2/PRL) * PRL - d2;
    AIN1        = [zeros( d1, params.L), AIN, zeros( d1, zeropad + params.L *2 + 1 + 500)]; % 500: Margin Timing error     
    if ( params.en == 0 )
        AOUT = AIN ;
        tprout.tau     = tau(1:PRL:d2);
        tprout.acc     = acc_error(1:PRL:d2);
        tprout.phase   = phase_error(1:PRL:d2);
        return;
    end
    AOUT      = zeros(d1,  d2 );
    if ( params.cal_init_tpr == 1 )
        tau_init = TPR_init(AIN1, training, params, T);
        tau         = ones(1, d2 + 1 + DLY*PRL ) * tau_init;
    end
    tau_dly_in = tau;
    %%  Feedback loop 
    for iSa  =1:PRL:size(AIN,2)
        nSa = iSa + PRL;
        % Timing Error recovery
        [ tau_frac, tau_int] = UpdateTiming( tau_dly_in(iSa) , T );
        SIdx = ( iSa :( iSa+PRL + (params.L * 2 - 1)) )- tau_int ;
        for idim=1:d1
            [AOUT(idim,iSa:iSa+PRL-1)] = TPR( AIN1(idim,SIdx), tau_frac, params);
        end

        % Matched filter         

        % Timing Error estimation
 
        decided = AOUT(iSa:iSa+PRL-1);
        phase_error(iSa) = TPE( AOUT(1,iSa:iSa+PRL-1), decided, params );

        % Loopfilter
        [tau(nSa), acc_error(nSa)] = ...
         TPRLoopFilter( tau(iSa), phase_error(iSa), acc_error(iSa), params);
        tau_dly_in(nSa+DLY*PRL)= tau(nSa);
        if ( params.fixed_bit == 2 ) 
        end
    end 
    
    if ( params.fixed_bit == 2 ) 
    end
    tprout.tau     = tau(1:PRL:d2);
    tprout.acc     = acc_error(1:PRL:d2);
    tprout.phase   = phase_error(1:PRL:d2);
    AOUT           = AOUT(:,1:d2);
end


function tau_init = TPR_init_old(AIN1, training, params, T)
   STEP =16;
    iSa = 1; idx=1;
    for tau_int =0:1
        for tau_frac=0:1/STEP:(1 -1/STEP)
            SIdx = ( iSa :( iSa+params.PRL + (params.L * 2 - 1)) ) + tau_int ;
             [AOUT_tmp] = TPR( AIN1(1,SIdx), tau_frac, params, T);
             phase_error(idx) = TPE( AOUT_tmp, training, params, T ) ; 
             idx=idx+1;
        end
    end
    tau_list = 0:1/STEP:(2 -1/STEP);
    [val, pos] = min(abs(phase_error));
    tau_init = tau_list(pos);
    if ( tau_int ~= 0 )
             tau_init = tau_init + params.OV;
    end
%     tau_init = - floor(pos/(STEP)) + 1/STEP*(mod(pos,(STEP)));
end


function [tau_init , phase_error]= TPR_init(AIN1, training, params, T)
   STEP =32;
    iSa = 1; idx=1;
    phase_error = zeros(STEP, size(AIN1,1));
     if ( params.fixed_bit == 2 ) 
         params.fixed_bit =1;
     end
    for tau_int =0:params.OV-1
        for tau_frac=0:1/STEP:(1 -1/STEP)
            for ich=1:size(AIN1,1)
                SIdx = ( iSa :( iSa+params.PRL + (params.L * 2 - 1)) ) + tau_int ;
                 [AOUT_tmp] = TPR( real(AIN1(ich,SIdx)), tau_frac, params);
                 phase_error(idx, ich) = TPE( AOUT_tmp, training, params ) ; 
            end
             idx=idx+1;
        end
    end
    tau_list = 0:1/STEP:(2 -1/STEP);
    smooth_len = ceil(STEP/4);
    phase_error_mean = mean(phase_error(:,1),2);
    phase_error_smooth = smooth(abs([ phase_error_mean(end-smooth_len:end); phase_error_mean; phase_error_mean(1:smooth_len)])); 
    phase_error_smooth1 = phase_error_smooth(smooth_len+1+(1:size(phase_error,1)));
    [val, pos] = min(phase_error_smooth1);
%     phase_error_sft = phase_error - [phase_error(2:end) phase_error(1)];
%     [val, pos] = max(abs(phase_error_sft));
    tau_init = tau_list(pos); 
    tau_init = - params.OV + tau_init  ;
%     figure; plot(phase_error_smooth1,'bs-');
end
