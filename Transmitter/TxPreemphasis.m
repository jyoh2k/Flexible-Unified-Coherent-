function AOUT = TxPreemphasis( AIN, params)    

%  Usage      : AOUT = TxPreemphasis( AIN, params, T )    
%  Function   : Preemphasis, Thmolinson Harashima precoding
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    
    AOUT =AIN;
    if ( params.en == 0 )
      return;    
    end

    for ii=1:size(AIN,1)
        out_filter= filter(params.b, params.a, AIN(ii,:));    
        txout_filter_1=  circshift(out_filter, round( -1*(length(params.b)+1)/2), 2);      
        AOUT(ii,:) = txout_filter_1 ;
    end
    
    if ( params.mod ~= 1)
        AOUT = mod(AOUT + params.mod, params.mod * 2) - params.mod;     
    end
    
 
end
