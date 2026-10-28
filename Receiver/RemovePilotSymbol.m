function [out]=  RemovePilotSymbol( in,   params )

%  Usage      : [out]=  RemovePilotSymbol( in,  sim, params )
%  Function   :
%     1. RemovePilotSymbol: Remove last symbols of each block.
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    out = in;
    if ( params.en == 0 )
        return;
    end
    if ( params.en == 4)
        termidx =[1:params.block_size_out*2:length(in)];
        termidx= reshape([termidx; termidx+1;],1,size(termidx,2)*2);
    else
        termidx =[1:params.block_size_out:length(in)];
    end 
    idx = setdiff([1:length(in)], termidx);
    out = in(:, idx);     
end
