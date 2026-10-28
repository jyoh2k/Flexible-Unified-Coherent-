function [signed_amp] =  SignedAmp( in, params)

%  Usage      : [signed_amp] =  SignedAmp( amp_in, sign_in, params)
%   Amplitude and signed bits are mixed for probability shaping in unit of
%   FEC frame.
%              
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Date       : 2020.May.01
%  Known bugs :

   if ( params.ps.en ==0 )
       signed_amp  =in;
       return;
   end

    amp_bit = log2(params.ps.level);
    
    num_fec_block = size(in,2)/params.fec.n;
    signed_amp = in;
    
    for iblk=1:num_fec_block
        idx1 = (iblk-1)*params.fec.n;
        idx2 = idx1 + params.fec.n;
        one_fec_frame = in(:, idx1+(1:params.fec.n));
        amp_in = one_fec_frame(:, (1:params.fec.n* amp_bit/(amp_bit+1)));
        sign_in = one_fec_frame(:, ((params.fec.n* amp_bit/(amp_bit+1))+1):end);
        for ibit=1:amp_bit
             signed_amp(:, (idx1+ ibit):(amp_bit+1):idx2) = amp_in(:, ibit:amp_bit:end);
        end        
        signed_amp(:, (idx1+amp_bit+ 1):(amp_bit+1):idx2)= sign_in;
    end

end 
