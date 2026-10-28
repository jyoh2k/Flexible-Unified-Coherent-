function [out]=  BlockTerminationRX( in,   params)

%  Usage      : [out]=  BlockTerminationRX( in,  params )
%  Function   :
%     1. Block Termination, last bit of block is removed.
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    out = in;
    if ( params.en == 0 )
        return;
    end
    
    if ( params.en == 3 ) 
        termidx = [ params.block_size:params.block_size:length(in)]; 
        idx = setdiff([1:length(in)], termidx);
        out = in(:, idx);
        return;
    else

        termidx =[];
        for iblk=params.block_size_in+1:params.block_size_out
          termidx = [termidx iblk:params.block_size_out:length(in)];
        end
        idx = setdiff([1:length(in)], termidx);
        out = in(:, idx);     
    end 
end
