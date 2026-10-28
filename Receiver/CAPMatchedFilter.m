function AOUT = CAPMatchedFilter(  AIN,  params, T  )    

%  Usage      :  AOUT = CAPMatchedFilter(  AIN,  params, T  )       
%  Function   :
%     1.      CAP matched filter    
%  Port 
%     1. AIN     : input signal
%     2. params  : general parameters
%     3. T       : data type ( for fixed simulation )
%     4. AOUT    : output signal  
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs

    if ( params.modulation_format == 1 )
        AOUT = AIN;
        return;
    end

  
    AOUT_cap =  0;%zeros(1,length(AIN)+filter_len-1);
    for idim=1:size(params.CAP.rx_filter,1)
        AOUT_cap = AOUT_cap + conv(AIN, params.CAP.rx_filter(idim, :));
    end
     
    AOUT = AOUT_cap(:, params.filter_len_2+(1:size(AIN,2))) ;