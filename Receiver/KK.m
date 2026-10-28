function [AOUT] = KK( AIN, params)
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

    if ( params.en == 0 )
        AOUT   = AIN;
        return;
    end

    A_amp   = sqrt(AIN); 
    A_phase = imag(hilbert(0.5*log( AIN))); 
    AOUT    = A_amp .* exp (1j*A_phase);
    AOUT    = AOUT - mean((AOUT));
end


%function AOUT = HibertTransform( AIN )
    %freq    = (fft(AIN));
%
    %max_idx = ( length(freq)-mod(freq,2) )/2;
    %positive_idx = 1:max_idx;
    %negative_idx = length(freq)-max_idx+1:length(freq);
%
    %freq_out = freq ; 
    %freq_out(positive_idx) = conj(freq(positive_idx));
    %AOUT = fft(freq_out);
%end
