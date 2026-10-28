function [AOUT, max_val] =  TxClipping( AIN,  params)  

    max_val = max(max(abs(AIN)));
    if ( params.ratio >= 1 )
        AOUT = AIN;
        return
    end
    
    for ich=1:size(AIN,1)
        if ( isreal(AIN))
            max_tmp = max(abs(AIN(ich,:)));
            if ( max_tmp > max_val)
                max_val = max_tmp;
            end
        else
            max_tmp = max(max(abs(real(AIN(ich,:)))), max(abs(imag(AIN(ich,:)))) );
            if ( max_tmp > max_val)
                max_val = max_tmp;
            end
        end 
    end
    
    clipp_val = max_val * params.ratio; 
    
    AOUT = AIN;
    for ich=1:size(AIN,1)
        if ( isreal(AIN))
            AOUT(ich,:) = max( -clipp_val, min ( clipp_val , AIN(ich,:)) ) ;
        else
            rAOUT = max( -clipp_val, min ( clipp_val , real(AOUT(ich,:)) )) ;
            iAOUT = max( -clipp_val, min ( clipp_val , imag(AOUT(ich,:)) )) ;
            AOUT(ich,:) = complex(rAOUT, iAOUT);
        end 
    end 
    
        
end
