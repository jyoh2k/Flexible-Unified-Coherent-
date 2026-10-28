function [ msg_out ]=  Deinterleaver( msg_in, params )

%  Usage      : [ msg_out ]=  Deinterleaver( msg_in, params )
%  Function   :
%     1.   
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    msg_out = msg_in;
    if (params.en == 0 )
        return;
    end
        
    ITL_block_size = length(params.fecperm);
    for ii=1:floor(length(msg_out)/ITL_block_size)
        msg_out(ITL_block_size*(ii-1)+1:ITL_block_size*ii) =   ...
            deintrlv( msg_out(ITL_block_size*(ii-1)+1:ITL_block_size*ii), params.fecperm ) ;
    end
    
end
