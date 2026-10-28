function OSNR_dB =  snr2osnr( SNR_dB, Rs)

%  Usage      : OSNR_dB =  snr2osnr( SNR_dB, Rs)
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    SNR = 10 .^(SNR_dB/10);
   
    GHz=1e9;
    BRef = 12.5 *GHz; %
    OSNR = SNR * Rs/2/BRef ;
    
    OSNR_dB = 10*log10(OSNR);
end 
