function AOUT =  TxArcCos( AIN,  params)  

    AOUT = AIN;
    if ( params.en == 0 )
        max_val = max(max(abs(AIN)));
        return
    end
     
    AIN_norm =  AIN * params.gain +  params.offset;
    for ich=1:size(AIN,1)
        if ( isreal(AIN))
            AOUT(ich,:) =acos(real(AIN_norm) ) ;
        else
            rAOUT = acos(real(AIN_norm) ) ;
            iAOUT = acos(imag(AIN_norm) ) ;
            AOUT(ich,:) = complex(rAOUT, iAOUT);
        end 
    end  
    AOUT = (AOUT - params.offset)/params.gain;        
end
