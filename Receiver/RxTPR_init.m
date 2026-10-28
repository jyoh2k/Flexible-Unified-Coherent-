function [AOUT, tprout] = RxTPR_init( AIN, training, params, T )  

%  Usage      :  AOUT = RxTPR( AIN, params, T )   
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
    tau         = ones(1, d2 + 1) * params.tau_init;
    acc_error   = zeros(1, d2 + 1) ;
    phase_error = zeros(1, d2 + 1) ;
    DLY         = 0;
    PRL         =  params.PRL; 
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
    
    iSa = 1;
    for tau_int =0:1
        for tau_frac=0:1/8:1
            SIdx = ( iSa :( iSa+PRL + (params.L * 2 - 1)) )- tau_int ;
             [AOUT_tmp] = TPR( AIN1(1,SIdx), tau_frac, params, T);
             phase_error = TPE( AOUT_tmp, training, params, T )
        end
    end
    %%  Feedback loop 
    for iSa  =1:PRL:size(AIN,2)
        nSa = iSa + PRL;
        % Timing Error recovery
        [ tau_frac, tau_int] = UpdateTiming( tau(iSa) , T );
        SIdx = ( iSa :( iSa+PRL + (params.L * 2 - 1)) )- tau_int ;
        for idim=1:d1
            [AOUT(idim,iSa:iSa+PRL-1)] = TPR( AIN1(idim,SIdx), tau_frac, params, T);
        end

        % Matched filter         

        % Timing Error estimation
 
        decided = AOUT(iSa:iSa+PRL-1);
        phase_error(iSa) = TPE( AOUT(1,iSa:iSa+PRL-1), decided, params, T );

        % Loopfilter
        [tau(nSa+DLY), acc_error(nSa+DLY)] = ...
         TPRLoopFilter( tau(iSa), phase_error(iSa), acc_error(iSa), params, T);
 
    end 

    tprout.tau     = tau(1:PRL:d2);
    tprout.acc     = acc_error(1:PRL:d2);
    tprout.phase   = phase_error(1:PRL:d2);
    AOUT           = AOUT(:,1:d2);
end


    
    iSa = 1; idx=1;
    for tau_int =0:1
        for tau_frac=0:1/8:1
            SIdx = ( iSa :( iSa+PRL + (params.L * 2 - 1)) ) + tau_int ;
             [AOUT_tmp] = TPR( AIN1(1,SIdx), tau_frac, params, T);
             phase_error(idx) = TPE( AOUT_tmp, training, params, T ) ; 
             idx=idx+1;
        end
    end
    [val, pos] = min(abs(phase_error));
    tau_init = -( - floor(pos/9) + 1/8*(mod(pos,9)));