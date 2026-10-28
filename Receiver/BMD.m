function [qamout, demapper_out, bmdout]  =  BMD( in,  decided, params) 

%  Usage      : [params]  =  Calculate_Sigma( demapper_in,decided_in,  params, T) 
%  Function   :  Calculate standard deviation of each level to obtain
%  BMD(Bit metric decoder)
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
 
   QAM_factor = params.QAM_factor;
   B_bit = params.Nbitspersymbol/QAM_factor;
   demapper_out = zeros( size(in,1) * QAM_factor, (size(in,2))*B_bit);

   %% Statistics
    [params]        = Calculate_Sigma( in,  decided, params) ;
     type_seq = params.type_seq;
   %% Main decoder??
    for istream=1:size(in,1)
        params.sigma = params.sigmai(istream,:);
        params.type_seq = real( type_seq);
        demapper_out((istream-1)*QAM_factor+1,:)     = Bitmetricdecoder( real(in(istream,:)),  params) ; 
         
        if ( ~isreal(in) )
            params.type_seq = imag( type_seq);
            params.sigma = params.sigmaq(istream,:);
            demapper_out((istream-1)*QAM_factor+2,:)     = Bitmetricdecoder( imag(in(istream,:)),  params ) ; 
        end        
    end
 
    
    %% Output
    bitout = demapper_out > 0;
    qamout  = zeros(size(bitout,1), size(bitout,2)/(B_bit));
     
    for bit_level=1:B_bit
        qamout = qamout + bitout( :, bit_level:B_bit:end) * 2^(bit_level-1);
    end
    bmdout = params;
end
