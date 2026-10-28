function AOUT = RxPostemphasis( AIN, params )    

%  Usage      : AOUT = RxPostemphasis( AIN, params )     
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    AOUT =AIN;
    
    if ( params.en == 0 )
      return;    
    else        
        for idim=1:size(AIN,1)            
            out_filter  = conv(AIN(idim,:), params.b); 
            txout_filter_1=  circshift(out_filter, round( -1*(length(params.b)+1)/2), 2);    
            AOUT(idim,:) = txout_filter_1 (1,1:size(AIN,2));         
        end
    end
    
    
 
end