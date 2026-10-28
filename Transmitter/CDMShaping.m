function AOUT = CDMShaping(  AIN, params, T  )    

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

    AOUT = AIN;
    if ( params.modulation_format ~= 4  )
        return;
    end

    Wlen = size(params.WalshCode,2); 
    for ichannel=1:size(AIN,1) 
        AINt   = reshape( AIN(ichannel,:) , Wlen,size(AIN,2)/Wlen );
        AOUTt  =  params.WalshCode(ichannel,:)' * AINt(1,:);
        AOUT(ichannel,:) =  ( AOUTt(:));
    end
    AOUT = sum( AOUT, 1); 

end
