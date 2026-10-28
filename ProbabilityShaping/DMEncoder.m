function [mapper] =  DMEncoder( dataf, params, sims) 

%  Usage      : mapper  =  DMEncoder( dataf, params, sims) 
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    if ( params.en == 0)
        mapper = dataf ;
        return;
    end 
 
    QAM_factor = params.QAM_factor; % For QAM, real/imaginary, PAM real only
    dm_fec_num =  size(dataf,2)/(params.signbit + params.k * params.num_dm_block_per_fec);
    amplitude_bit = log2(params.level);
    code_size = params.n * amplitude_bit *  params.num_dm_block_per_fec + params.signbit;
    source_size = params.k *   params.num_dm_block_per_fec + params.signbit;
    code_offset = params.n * amplitude_bit *  params.num_dm_block_per_fec ;
    source_offset = params.k *   params.num_dm_block_per_fec ;
    
    
    mapper = zeros( size(dataf,1), dm_fec_num * code_size);
    for iblk=1:dm_fec_num
        idx1 = (iblk-1)* (source_size);
        idx2 = (iblk-1)* (code_size);
        for idm=1:params.num_dm_block_per_fec 
            idx3 = idx1 + (idm -1)*params.k ;
            idx4 = idx2 + (idm -1)*params.n * amplitude_bit;
            for istream=1:size(dataf,1)
                ampout = params.ccdm.encode( dataf(istream, (idx3 +(1:params.k))))  ;  
                mapper(istream, idx4 + (1:params.n * amplitude_bit) ) = amp2bit(ampout, amplitude_bit) ;                   
            end
        end 
        fecin    = dataf(:, idx1+source_offset+(1:params.signbit));
        mapper(:, idx2+code_offset +(1:params.signbit)) = fecin;
    end     
end 

function out = amp2bit(in, Nbps)
    out =zeros(1, length(in) * Nbps);
    amp = dec2bin(in, Nbps);
     
    for ibit=1:Nbps
        out(ibit:Nbps:end) = bin2dec(amp(:, Nbps- ibit+1))';
    end

end
