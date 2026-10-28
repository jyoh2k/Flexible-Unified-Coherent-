function AOUT =  TxArcSin( AIN,  params)  

    if ( params.en == 0 )
        AOUT = AIN;
        return
    end
    
    [AOUT_tmp, max_val] =  TxClipping( AIN,  params) ; 
    mzm_in = pi*( AOUT_tmp/params.Vpi_RF  +  params.Vbias1 /params.Vpi_DC);
    for ich=1:size(AIN,1)
        if ( isreal(AIN))
            AOUT(ich,:) =acos(real(mzm_in) ) ;
        else
            rAOUT = acos(real(mzm_in) ) ;
            iAOUT = acos(imag(mzm_in) ) ;
            AOUT(ich,:) = complex(rAOUT, iAOUT);
        end 
    end 
    
        
end
