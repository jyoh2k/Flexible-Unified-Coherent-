function [AOUT] = KK1( AIN, params)
%  Usage      :  AOUT = KK( AIN, params )   
%
%  Function   :Kramers-Kronig receiver
%     Field recontruction from intensity
%  Port
%     1. AIN        : Original signal
%     2. params     : KK parameter
%     3. AOUT       : Reconstructed signal
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Check if CPCR is bigger

    AOUT   = AIN;
    if ( params.en == 0 )        
        return;
    end

    for ich=1:size(AIN,1)
        A_amp   = sqrt(AIN(ich,:)); 
        A_phase = imag(hilbert(0.5*log( AIN(ich,:)))); 
        AOUT1    = A_amp .* exp (1j*A_phase);
        AOUT1    = AOUT1 * exp(1j*pi/4);
        AOUT(ich,:)    = AOUT1 - mean((AOUT1));
    end
end
