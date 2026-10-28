function [out]=  BlockTermination( in,  sim, params )

%  Usage      : [out]=  BlockTermination( in,  sim, params )
%  Function   :
%     1. Block Termination, one "0" bit is attached in every block.
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    if ( params.en == 0 )
        out = in ;
        return
    end

    if ( params.en == 2 )         
        [d1,d2]=size(in);
        bl = params.block_size_in;
        num_block = ceil(length(in) / bl);
        zeropad = num_block *  bl - length(in);
        out = zeros(d1, num_block * params.block_size_out);
        termbits     = DataGen( sim.dataf, (num_block ) * length(params.bits),  0 );
        for ich=1:d1
            in_prl = reshape([in(ich,:) zeros(1, zeropad)],  bl, num_block); 
            tr_prl=reshape(termbits, length(params.bits) , num_block);
            in_prl = [in_prl; tr_prl;];
            out(ich,:) = in_prl(1:end);
        end
        return 
    end
    
   if ( params.en == 1 )
        [d1,d2]=size(in);
        bl = params.block_size_in;
        num_block = ceil(length(in) / bl);
        zeropad = num_block *  bl - length(in);
        out = zeros(d1, num_block * params.block_size_out);
        for ich=1:d1
            in_prl = reshape([in(ich,:) zeros(1, zeropad)],  bl, num_block); 
            for ibit=1:length(params.bits)
                in_prl = [in_prl;   params.bits(ibit) * ones(1, num_block); ];
            end
            out(ich,:) = in_prl(1:end);
        end
    end

   if ( params.en == 3 ) % termination symbol
        [d1,d2]=size(in);
        bl = params.block_size - size(params.symbol,2);
        num_block = ceil(length(in) / bl);
        zeropad = num_block *  bl - length(in);
        out = zeros(d1, num_block * params.block_size);
        for ich=1:d1
            in_prl = reshape([in(ich,:) zeros(1, zeropad)],  bl, num_block); 
            for ibit=1:length(params.symbol)
                in_prl = [in_prl;   params.symbol * ones(1, num_block); ];
            end
            out(ich,:) = in_prl(1:end);
        end
    end
end
