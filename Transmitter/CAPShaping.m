function AOUT = CAPShaping(  AIN,  params, T  )    

%  Usage      :  AOUT = CAPShaping(  AIN,  params, T  )       
%  Function   :
%     1.      CAP shaping filter
%  Port 
%     1. AIN     : input signal
%     2. params  : general parameters
%     3. T       : data type ( for fixed simulation )
%     4. AOUT    : output signal  
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs

    if ( params.modulation_format == 1 ||  params.modulation_format == 4 )
        AOUT = AIN;
        return;
    end
 
    AOUT_cap =  conv(real(AIN), params.CAP.tx_filter(1, :));
    AOUT_cap = AOUT_cap + conv(imag(AIN), params.CAP.tx_filter(2, :));
     
    AOUT = AOUT_cap(:,params.filter_len_2+(1:length(AIN))) ;
end
