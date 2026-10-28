function [AOUT] = TPR( AIN, tau_frac, params)
%  Usage      :  AOUT = TPE( AIN, params )   
%
%  Function   :
%     1. Timing phase recovery
%     2. AIN        : Original signal
%     4. tau_frac   : Fractional part of estimated timing error
%     3. params     : TPR parameter
%     4. T          : Reserved for fixed sim.
%     5. AOUT       : Resampled signal
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   

    FilterLength = params.FilterLength ;%params.L + (length(params.time_resp)-1)/2;
    PRL          = size(AIN,2) - (FilterLength)*2 ;
    OV           = params.OV;

    %% Data Align  
    AIN =fie_c( AIN, params.T.In) ; 
    AOUT = AIN(1, 1:PRL);

    %% Interpolation     
    tau_frac =fie_r( tau_frac, params.T.Tau_frac) ;

    tim_filterf =sinc(tau_frac+(-params.L:params.L)) ;
    tim_filterf = conv(tim_filterf, params.time_resp);
    tim_filterf =fie_r(tim_filterf, params.T.TPRFilter ) ;
   
    for iidx1=1:OV:(PRL )     
        for iidx=(0):(OV -1)
            iSa_idx1 = iidx+iidx1+FilterLength +(-FilterLength:FilterLength);
            received_mul = tim_filterf .* AIN( iSa_idx1);
            received_mul = fie_c(received_mul, params.T.TPRMul) ; 
            if ( params.fixed_bit == 2 ) 
            end
            AOUT( iidx+iidx1 ) = sum( received_mul);
        end   
    end 
    AOUT = fie_c(AOUT, params.T.TPRSum) ;
    
    %%
    if ( params.fixed_bit == 2 ) 
    end 
end 