function AOUT = TxPreemphasis( AIN, params )    

%  Usage      : AOUT = TxPreemphasis( AIN, params )    
%  Function   : Preemphasis, Thmolinson Harashima precoding
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    
    AOUT =AIN;
    if ( params.en == 0 )
      return;    
    end

    coef = params.b(end:-1:1);
    AOUT = FIR(AIN, coef, params);

    if ( params.fixed_bit == 2 ) 
    end 
end
