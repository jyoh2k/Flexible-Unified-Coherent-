function AOUT =  TxArcCosIm( AIN,  params)  

    AOUT = AIN;
    if ( params.en == 0 )
        max_val = max(max(abs(AIN)));
        return
    end
    
    [AIN_clip, max_val] =  TxClipping( AIN,  params) ;  
    AIN_norm =  (AIN_clip   +  max_val)* params.in_gain;
    AIN_sqrt = sqrt(AIN_norm);
    for ich=1:size(AIN,1)
        if ( isreal(AIN))
            AOUT(ich,:) =acos(real(AIN_sqrt) ) ;
        else
            rAOUT = acos(real(AIN_sqrt) ) ;
            iAOUT = acos(imag(AIN_sqrt) ) ;
            AOUT(ich,:) = complex(rAOUT, iAOUT);
        end 
    end  
    AOUT = -(AOUT - params.out_offset)/params.out_gain;        
end
