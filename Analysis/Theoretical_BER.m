function [X_coor, Pb] = Theoretical_BER( SNRdB,params)

%  Usage      : Theoritic_BER( SNRdB, params)
%  Function   :
%     1. Theroretical BER (Gray code)
%         QAM : http://www.dsplog.com/2012/01/01/symbol-error-rate-16qam-64qam-256qam/
%         PAM : Behrouz A.F. and Sophia C.F. Data Communication and Networking,
 %                    McGraw-Hill, New York. (2007) ISBN-13: 978-0-07-296775-3
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
%

    Nbitspersymbol = params.Nbitspersymbol ;

    X_coor = SNRdB;
    %EbNodB = SNRdB - 10 * log10( BitRate /Bandwidth);
    EbNodB = SNRdB /Nbitspersymbol;
    EbNo= db2pow(EbNodB);
    SNR =  db2pow(SNRdB);
    SNR =  10 .^(SNRdB/10);
    M=2^Nbitspersymbol;
    k      = sqrt(1/((2/3)*(M-1))); 
    if ( params.QAM_factor == 1 ) % PAM 
        x=SNR/sqrt(2*(M-1));
        Pb=(M-1)/M*erfc(x);
    else
        x= k * sqrt(SNR);
        Ps = 2*(1-1/sqrt(M)) *erfc(x) - ( 1-2/sqrt(M)+1/M)*(erfc(x) .^2);
        Pb=(1/Nbitspersymbol)*Ps;
    end 

end


% theorySer(jj,:) = 2*(1-1/sqrt(M(jj)))*erfc(k*sqrt((10.^(EsN0dB/10)))) ...
% 	              - (1-2/sqrt(M(jj)) + 1/M(jj))*(erfc(k*sqrt((10.^(EsN0dB/10))))).^2;