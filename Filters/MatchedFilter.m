function [ out  ]=  MatchedFilter( in, params )

%  Usage      : [ out  ]=  MatchedFilter( in, params )
%
%  Function   :
%     1. out :output 
%     2. in : input 
%     3. params : parameters
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :
%
%% Matched filter 
    out = in ;
    if ( params.en == 0 )        
        return;
    end

    for idim=1:size(in,1)
        out_filter  = conv(in(idim,:), params.time_resp);
        txout_filter_1=  out_filter( (length(params.time_resp)-1)/2 + ( 1:length(in)));
        out(idim,:) = txout_filter_1 ;
    end
end