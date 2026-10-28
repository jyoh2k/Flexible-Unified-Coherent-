function [AOUT, AWGN] = ASENoise( AIN, OSNRdB, Rs, en)

%  Usage      : [AOUT, AWGN] = ASENoise( AIN, OSNRdB, Rs, en)
%
%  Function   :
%     1. Generate AWGN noise and add it into original signal       
%     2. AIN        : Original signal
%     3. OSNRdB     : OSNR in dB
%     4. AOUT       : Signal with AWGN noise
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    active_data = 1:size(AIN,2);
    SNRdB = osnr2snr(OSNRdB, Rs); 

    if ( en == 0 )
            AOUT =  AIN ;
            AWGN =  zeros(size( AIN));
    else
            signal_energy = mean( AIN .* conj(AIN),2 );
            SNR=10 .^(SNRdB/10);
            No=(signal_energy ./SNR);
            noise= zeros(size(AIN));
            for ii=1:size(AIN,1)
                noise(ii,:)=sqrt(No(ii)/2) *(randn(1, size(AIN,2)) + 1j*randn(1, size(AIN, 2)));
            end 
            AWGN = noise;
            AOUT =  AIN + AWGN;
    end

end
