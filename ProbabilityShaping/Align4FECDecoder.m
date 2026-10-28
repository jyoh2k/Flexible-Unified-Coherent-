function [fecin] =  Align4FECDecoder( demapper_out, params)

%  Usage      :  [fecin] =  Align4FECDecoder( demapper_out, params)
%   Amplitude and signed bits are mixed for probability shaping, 
%              
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Date       : 2020.May.01
%  Known bugs :


   if ( params.ps.en ==0 )
       fecin  =demapper_out;
       return;
   end

   qam_bit = (params.Nbitspersymbol/params.QAM_factor) ;      
    
    num_fec_block = size(demapper_out,2)/params.fec.n;
    fecin = demapper_out;
     
    sign_idx = [qam_bit:qam_bit:params.fec.n]; 
    amp_idx = setdiff([1:1:params.fec.n], sign_idx); 
    sign_idx1 = [length(amp_idx)+1:params.fec.n]; 
    amp_idx1 = [1:length(amp_idx)];
    for iblk=1:num_fec_block
        idx1 = (iblk-1)*params.fec.n; 
        one_fec_frame = demapper_out(:, idx1+(1:params.fec.n));
        fecin(:, idx1+amp_idx1) = one_fec_frame(:, amp_idx);
        fecin(:, idx1+sign_idx1) = one_fec_frame(:, sign_idx); 
    end
    
end 
