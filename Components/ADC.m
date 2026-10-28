function AOUT =  ADC( AIN, params) 

%  Usage      : AOUT =  ADC( AIN, params )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
 
    BIT = params.BIT;
    if ( BIT <= 0 )
        AOUT =  params.gain * AIN ;
    else
        AIN  = params.gain * AIN; 
        SNR = ENob2SNR( params.ENob ); 
        if ( params.T.signed == 1 )
            LIM = (2^(params.T.wordl -1)-1)/ 2^(params.T.fracl) ;
        else
            LIM = (2^(params.T.wordl) - 1 )/ 2^(params.T.fracl)  ;
        end
        Noise = LIM / 10^(SNR/10) *(randn(size(AIN,1), size(AIN,2)) );
        if ( isreal(AIN) ==  0 )
            Noise = Noise + LIM / 10^(SNR/10) *(randn(size(AIN,1), size(AIN,2)) ) * 1j;
        end
        if ( params.nonoise == 0 )
            AIN = AIN + Noise;
        end
        AIN_bw = ChBandwidth( AIN, params.FilterCoef, params.bandwidth_en);
        
        if ( isreal(AIN) == 1 )
            AOUT  = fie_r( real(AIN_bw), params.T); 
        else
            AOUTr  = fie_r( real(AIN_bw), params.T); 
            AOUTi  = fie_r( imag(AIN_bw), params.T); 
            AOUT = complex(AOUTr, AOUTi);
        end
    end
end 
