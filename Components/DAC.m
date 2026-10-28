function AOUT_bw =  DAC( AIN,  params)

%  Usage      : AOUT_bw =  DAC( AIN, params )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    BIT = params.T.wordl;
    
    if ( BIT <= 0 )
        AOUT = params.gain *AIN ;
    else
        if ( params.T.signed == 1 )
            LIM = (2^(params.T.wordl -1)-1)/ 2^(params.T.fracl) ;
        else
            LIM = (2^(params.T.wordl) - 1 )/ 2^(params.T.fracl)  ;
        end
        
        AOUTr  = fie_r( real(AIN), params.T); 
        AOUTi  = fie_r( imag(AIN), params.T); 
        SNR = ENob2SNR( params.ENob ); 
        
        if ( isreal(AIN))
            AOUT =AOUTr;
            Noise = LIM / 10^(SNR/10) *(randn(1, size(AIN,2)) );
        else
            AOUT = complex(AOUTr, AOUTi);
            Noise = LIM / 10^(SNR/10) *(randn(size(AIN,1), size(AIN,2)) );
            Noise = Noise + LIM / 10^(SNR/10) *(randn(size(AIN,1), size(AIN,2)) ) * 1j ;
        end

        
        if ( params.nonoise == 0 )
            AOUT = AOUT + Noise;
        end
        AOUT  = params.gain * AOUT;  
    end
    
    AOUT_bw = ChBandwidth( AOUT, params.FilterCoef, params.bandwidth_en);
    
end 

