function [dataf] =  DMDecoder( mapperin, params) 

%  Usage      : dataf  =  DMDecoder( mapperin, params) 
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :


    if ( params.en == 0)
        dataf = mapperin ;
        return;
    end 
 
    QAM_factor = params.QAM_factor; 
    amplitude_bit = log2(params.level);
    dm_fec_num =  size(mapperin,2)/(params.signbit + params.n * params.num_dm_block_per_fec * amplitude_bit);
    code_size = params.n * amplitude_bit *  params.num_dm_block_per_fec + params.signbit;
    source_size = params.k *   params.num_dm_block_per_fec + params.signbit;
    code_offset = params.n * amplitude_bit *  params.num_dm_block_per_fec ;
    source_offset = params.k *   params.num_dm_block_per_fec ;
    
    
    dataf = zeros( size(mapperin,1), dm_fec_num * source_size);
    for iblk=1:dm_fec_num
        idx1 = (iblk-1)* (code_size);
        idx2 = (iblk-1)* (source_size);
        for idm=1:params.num_dm_block_per_fec 
            idx3 = idx1 + (idm -1)*params.n  * amplitude_bit ;
            idx4 = idx2 + (idm -1)*params.k ;
            for istream=1:size(dataf,1)
                dm_bit_in = mapperin(istream, (idx3+(1:params.n * amplitude_bit)));
                dm_sym_in = bit2amp(dm_bit_in, amplitude_bit);
                dm_out = params.ccdm.decode( dm_sym_in);
                dataf(istream, idx4 + (1:params.k) ) = dm_out;
            end
        end 
        fecout = mapperin(:, idx1+code_offset +(1:params.signbit));
        dataf(:, idx2+source_offset+(1:params.signbit)) = fecout;
    end     
end 

function out = bit2amp(in, Nbps)
    out =zeros(1, length(in) / Nbps);
    level = 1;
    for ibit=1:Nbps
        out   = out +  in(ibit:Nbps:end) * level;
        level = level * 2;
    end

end
