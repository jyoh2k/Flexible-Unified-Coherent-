function [ out ]=  IFFTnAddGI( in, params )

%  Usage      :  out =  IFFTnAddGI( in, params )
%  Function   :
%     1.       
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    Nsymbol = ceil(size(in,2) /params.NFFT);
    Nzeropad = size(in,2) - Nsymbol * params.NFFT ;
    Nout =   Nsymbol * params.NSamplepersymbol;
    out = zeros(size(in,1), Nout); 
    
    
    for ich=1:size(in,1)
       power_sc = ones(params.NFFT,1);
       power_sc(params.SubcarrierIndex,1) = params.power_sc(ich, params.SubcarrierIndex);
       in_pad = [in(ich,:) zeros(1,Nzeropad)];
       in1 = reshape( in_pad,  params.NFFT , Nsymbol ) .* (power_sc * ones(1,Nsymbol));  
       ifftout = ifft(in1, [],1); 
       guardout = ifftout(params.CPindex,:);
       out(ich, :) = transpose(guardout(:));
    end 

end 
