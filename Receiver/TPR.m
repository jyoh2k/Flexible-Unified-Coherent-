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
    PRL          = size(AIN,2) - (FilterLength)*2;
    OV           = params.OV;

    %% Data Align  
    AOUT = AIN(1, 1:PRL);

    %% Interpolation     

    tim_filterf =sinc(tau_frac+(-params.L:params.L)) ;
    tim_filterf = conv(tim_filterf, params.time_resp);
    
%     for iidx1=1:(PRL )       
%             received_mul = tim_filterf .* AIN( iidx1+FilterLength +(-FilterLength:FilterLength));
%             AOUT( iidx1 ) = sum( received_mul);         
%     end 
    
    received_mul1 = zeros(length(tim_filterf), PRL);
    for iidx =1:length(tim_filterf)
        received_mul1(iidx, :) = tim_filterf(iidx) * AIN(iidx+(0:PRL-1));
    end
    AOUT = sum(received_mul1,1);
end
